import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get/get.dart' hide Response;
import 'package:monprof/corps/utils/constantes.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/cours/data/models/video_download_state.dart';
import 'package:path_provider/path_provider.dart';

class VideoController extends GetxController {
  final Cours cours;
  late final String fileName;

  VideoController({required this.cours}) {
    final creationKey = cours.created_at
        .replaceAll('-', '_')
        .replaceAll(':', '_')
        .replaceAll('.', '');
    // Conserve le nom historique afin que les vidéos déjà téléchargées restent
    // disponibles après la mise à jour de l’application.
    fileName = '$creationKey.mprf.mp4';
  }

  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  Directory? directory;
  File files = File('');

  double progrees = 0;
  bool loading = false;
  bool isDownloaded = false;
  bool hasPartialDownload = false;
  int downloadedBytes = 0;
  int? totalBytes;
  String? lastDownloadError;
  int _lastPersistedPercent = -1;

  String get progressLabel => '${(progrees * 100).round()} %';

  Future<Directory> getDirectory() async {
    final result = Platform.isIOS
        ? await getApplicationSupportDirectory()
        : await getExternalStorageDirectory();

    if (result != null) return result;
    return getApplicationSupportDirectory();
  }

  File get _completedFile => File('${directory!.path}/$fileName');

  File get _partialFile => File('${directory!.path}/$fileName.part');

  File get _metadataFile => File('${directory!.path}/$fileName.download.json');

  Future<void> _prepareDirectory() async {
    directory ??= await getDirectory();
    if (!await directory!.exists()) {
      await directory!.create(recursive: true);
    }
  }

  Future<bool> supprimer() async {
    await _prepareDirectory();
    _cancelToken?.cancel('Téléchargement supprimé par l’utilisateur.');

    var deleted = false;
    for (final file in [_completedFile, _partialFile, _metadataFile]) {
      if (await file.exists()) {
        await file.delete();
        deleted = true;
      }
    }

    final playbackFile = await _playbackFile();
    if (await playbackFile.exists()) {
      await playbackFile.delete();
    }

    files = File('');
    loading = false;
    isDownloaded = false;
    hasPartialDownload = false;
    downloadedBytes = 0;
    totalBytes = null;
    progrees = 0;
    lastDownloadError = null;
    update();

    return deleted;
  }

  Uint8List decryptFile(Uint8List encryptedData, String base64Key) {
    final keyString =
        base64Key.startsWith('base64:') ? base64Key.substring(7) : base64Key;
    final keyBytes = base64.decode(keyString);
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV(encryptedData.sublist(0, 16));
    final data = encryptedData.sublist(16);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decryptBytes(encrypt.Encrypted(data), iv: iv);

    return Uint8List.fromList(decrypted);
  }

  Future<File> _playbackFile() async {
    final temporaryDirectory = await getTemporaryDirectory();
    return File('${temporaryDirectory.path}/monprof-course-${cours.id}.mp4');
  }

  Future<File> getFileDecrypted(File cryptedFile) async {
    try {
      final encryptedData = await cryptedFile.readAsBytes();
      final decryptedData = decryptFile(encryptedData, encryptedKey);
      final decryptedFile = await _playbackFile();
      await decryptedFile.writeAsBytes(decryptedData, flush: true);
      return decryptedFile;
    } catch (_) {
      // Les objets MinIO actuels sont stockés en clair. Le fallback conserve la
      // compatibilité avec les anciennes vidéos Firebase chiffrées.
      return cryptedFile;
    }
  }

  Future<bool> saveVideo() async {
    if (loading) return false;

    await _prepareDirectory();
    await _restoreDownloadState();

    loading = true;
    isDownloaded = false;
    lastDownloadError = null;
    _cancelToken = CancelToken();
    await _persistState(
        status: 'downloading', isDownloading: true, force: true);
    update();

    try {
      var offset =
          await _partialFile.exists() ? await _partialFile.length() : 0;
      var response = await _openDownload(offset);

      if (response.statusCode == HttpStatus.requestedRangeNotSatisfiable) {
        final remoteTotal = _totalFromContentRange(
          response.headers.value('content-range'),
        );
        if (remoteTotal != null && remoteTotal == offset && offset > 0) {
          totalBytes = remoteTotal;
          await _completeDownload();
          return true;
        }

        await _partialFile.writeAsBytes(const []);
        offset = 0;
        response = await _openDownload(0);
      }

      final supportsResume = response.statusCode == HttpStatus.partialContent;
      if (offset > 0 && !supportsResume) {
        // Le serveur a ignoré Range : on repart proprement pour ne jamais
        // concaténer deux vidéos et produire un fichier corrompu.
        await _partialFile.writeAsBytes(const []);
        offset = 0;
      }

      downloadedBytes = offset;
      totalBytes = _responseTotal(response, offset);
      hasPartialDownload = offset > 0;
      _updateProgress();

      final body = response.data;
      if (body == null) {
        throw const HttpException('Réponse vidéo vide.');
      }

      final sink = _partialFile.openWrite(
        mode: offset > 0 ? FileMode.append : FileMode.write,
      );
      try {
        await for (final chunk in body.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length.toInt();
          hasPartialDownload = downloadedBytes > 0;
          _updateProgress();
          await _persistState(
            status: 'downloading',
            isDownloading: true,
          );
          update();
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      final expectedTotal = totalBytes;
      if (expectedTotal != null && downloadedBytes < expectedTotal) {
        throw HttpException(
          'Téléchargement incomplet ($downloadedBytes/$expectedTotal octets).',
        );
      }

      await _completeDownload();
      return true;
    } catch (error) {
      loading = false;
      downloadedBytes =
          await _partialFile.exists() ? await _partialFile.length() : 0;
      hasPartialDownload = downloadedBytes > 0;
      isDownloaded = await _completedFile.exists();
      if (isDownloaded) files = _completedFile;
      _updateProgress();
      lastDownloadError = error.toString();
      await _persistState(
        status: hasPartialDownload ? 'paused' : 'failed',
        isDownloading: false,
        error: lastDownloadError,
        force: true,
      );
      update();

      final wasCancelled =
          error is DioException && error.type == DioExceptionType.cancel;
      if (!wasCancelled) {
        loger(error);
        Notify.toastError(
            'Téléchargement interrompu. Vous pourrez le reprendre.'.tr);
      }
      return false;
    } finally {
      _cancelToken = null;
      update();
    }
  }

  Future<Response<ResponseBody>> _openDownload(int offset) {
    return _dio.get<ResponseBody>(
      cours.video_url,
      cancelToken: _cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: true,
        headers: offset > 0 && cours.supportsRange
            ? {'Range': 'bytes=$offset-'}
            : null,
        validateStatus: (status) =>
            status != null &&
            ((status >= 200 && status < 300) ||
                status == HttpStatus.requestedRangeNotSatisfiable),
      ),
    );
  }

  int? _responseTotal(Response<ResponseBody> response, int offset) {
    final rangeTotal = _totalFromContentRange(
      response.headers.value('content-range'),
    );
    if (rangeTotal != null) return rangeTotal;

    final contentLength = int.tryParse(
      response.headers.value(Headers.contentLengthHeader) ?? '',
    );
    if (contentLength == null) return null;

    return response.statusCode == HttpStatus.partialContent
        ? offset + contentLength
        : contentLength;
  }

  int? _totalFromContentRange(String? contentRange) {
    if (contentRange == null) return null;
    final match = RegExp(r'/([0-9]+)$').firstMatch(contentRange);
    return int.tryParse(match?.group(1) ?? '');
  }

  void _updateProgress() {
    final total = totalBytes;
    progrees =
        total != null && total > 0 ? (downloadedBytes / total).clamp(0, 1) : 0;
  }

  Future<void> _completeDownload() async {
    if (await _completedFile.exists()) {
      await _completedFile.delete();
    }
    await _partialFile.rename(_completedFile.path);

    files = _completedFile;
    downloadedBytes = await _completedFile.length();
    totalBytes ??= downloadedBytes;
    progrees = 1;
    loading = false;
    isDownloaded = true;
    hasPartialDownload = false;
    lastDownloadError = null;
    await _persistState(
      status: 'completed',
      isDownloading: false,
      isComplete: true,
      force: true,
    );
    update();
  }

  Future<void> _persistState({
    required String status,
    required bool isDownloading,
    bool isComplete = false,
    bool force = false,
    String? error,
  }) async {
    final percent = (progrees * 100).floor();
    if (!force && percent == _lastPersistedPercent) return;
    _lastPersistedPercent = percent;

    final state = VideoDownloadState(
      courseId: cours.id,
      fileName: fileName,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
      isDownloading: isDownloading,
      isDownloaded: isComplete,
      status: status,
      lastError: error,
      updatedAt: DateTime.now(),
    );
    await _metadataFile.writeAsString(jsonEncode(state.toMap()), flush: true);
  }

  Future<VideoDownloadState?> _readPersistedState() async {
    if (!await _metadataFile.exists()) return null;

    try {
      final decoded = jsonDecode(await _metadataFile.readAsString());
      return VideoDownloadState.fromMap(
        Map<String, dynamic>.from(decoded as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _restoreDownloadState() async {
    await _prepareDirectory();
    final persisted = await _readPersistedState();

    if (await _completedFile.exists()) {
      files = _completedFile;
      downloadedBytes = await _completedFile.length();
      totalBytes = persisted?.totalBytes ?? downloadedBytes;
      isDownloaded = true;
      hasPartialDownload = false;
      loading = false;
      progrees = 1;
      return;
    }

    downloadedBytes =
        await _partialFile.exists() ? await _partialFile.length() : 0;
    totalBytes = persisted?.totalBytes;
    hasPartialDownload = downloadedBytes > 0;
    isDownloaded = false;
    loading = false;
    lastDownloadError = persisted?.lastError;
    _updateProgress();

    // Si l’application a été tuée pendant le transfert, l’état persistant
    // « downloading » est récupéré comme « paused », prêt à reprendre.
    if (persisted?.isDownloading == true) {
      await _persistState(
        status: 'paused',
        isDownloading: false,
        force: true,
      );
    }
  }

  Future<void> existCour() async {
    await _restoreDownloadState();
    update();
  }

  Future<bool> downloadvideo() => saveVideo();

  @override
  void onClose() {
    _cancelToken?.cancel('Contrôleur fermé.');
    super.onClose();
  }
}
