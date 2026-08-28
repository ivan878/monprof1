import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/prepa/cours/data/models/video_download_model.dart';
import 'package:monprof/prepa/cours/data/services/cours_service.dart';
import 'package:path_provider/path_provider.dart';

/// Téléchargement de vidéos avec reprise après interruption.
///
/// Les octets sont écrits dans un fichier `.part` en mode ajout. À la reprise,
/// sa taille donne l'offset et un en-tête `Range: bytes=N-` demande la suite —
/// rien de déjà reçu n'est retéléchargé. Le fichier n'est renommé sous son nom
/// définitif qu'une fois complet : un `.part` ne peut donc jamais être pris
/// pour une vidéo lisible.
///
/// L'empreinte du fichier distant est mémorisée au premier octet. Si elle
/// change entre deux tentatives — vidéo re-chiffrée, nouvelle version — le
/// fragment est jeté : le compléter mêlerait deux versions et produirait un
/// fichier corrompu.
class VideoDownloadManager {
  final Dio dio;
  final HiveService hiveService;
  final PrepaCoursService coursService;

  VideoDownloadManager({
    required this.dio,
    required this.hiveService,
    required this.coursService,
  });

  final Map<String, CancelToken> _active = {};

  String _key(String coursId, String? matiereId) =>
      '${coursId}_${matiereId ?? 'none'}';

  /// État persisté d'un téléchargement, ou `null` s'il n'y en a jamais eu.
  VideoDownloadModel? stateOf(String coursId, String? matiereId) =>
      hiveService.getDownload(coursId, matiereId);

  bool isRunning(String coursId, String? matiereId) =>
      _active.containsKey(_key(coursId, matiereId));

  /// Interrompt le téléchargement en conservant les octets déjà reçus.
  void pause(String coursId, String? matiereId) {
    final token = _active.remove(_key(coursId, matiereId));
    token?.cancel('Mis en pause');
  }

  /// Abandonne le téléchargement et supprime le fragment.
  Future<void> cancel(String coursId, String? matiereId) async {
    pause(coursId, matiereId);
    final state = hiveService.getDownload(coursId, matiereId);
    if (state != null) {
      await _deleteQuietly(state.partPath);
      hiveService.deleteDownload(coursId, matiereId);
    }
  }

  /// Démarre ou reprend le téléchargement.
  ///
  /// [onProgress] reçoit les octets reçus et le total attendu.
  /// Retourne l'état final : `completed`, `paused` (reprenable) ou `failed`.
  Future<VideoDownloadModel> download({
    required String coursId,
    String? matiereId,
    required String url,
    required bool isCrypted,
    void Function(int received, int total)? onProgress,
  }) async {
    final key = _key(coursId, matiereId);
    if (_active.containsKey(key)) {
      throw StateError('Un téléchargement est déjà en cours pour ce cours');
    }

    final paths = await _resolvePaths(coursId, matiereId, url);
    var state = hiveService.getDownload(coursId, matiereId) ??
        VideoDownloadModel(
          coursId: coursId,
          matiereId: matiereId,
          url: url,
          filePath: paths.finalPath,
          partPath: paths.partPath,
          isCrypted: isCrypted,
          updatedAt: DateTime.now(),
        );

    // Métadonnées distantes : taille attendue et empreinte de validation.
    String? remoteEtag;
    int remoteSize = 0;
    try {
      final meta = await coursService.getVideoMetadata(coursId);
      remoteSize = (meta['size'] as num?)?.toInt() ?? 0;
      remoteEtag = meta['etag']?.toString();
    } catch (e) {
      // Sans métadonnées, on peut encore télécharger depuis zéro.
      loger('[Download] métadonnées indisponibles pour $coursId : $e');
    }

    var offset = await _partSize(state.partPath);

    // Le fichier distant a changé : le fragment ne correspond plus.
    final staleFragment = offset > 0 &&
        remoteEtag != null &&
        state.etag != null &&
        state.etag != remoteEtag;

    // Fragment plus gros que la cible : incohérent, on repart de zéro.
    final oversized = remoteSize > 0 && offset > remoteSize;

    if (staleFragment || oversized) {
      loger('[Download] fragment obsolète pour $coursId — reprise annulée');
      await _deleteQuietly(state.partPath);
      offset = 0;
    }

    // Déjà complet : il ne reste qu'à finaliser.
    if (remoteSize > 0 && offset == remoteSize) {
      return _finalize(state, offset, remoteSize, remoteEtag);
    }

    state = state.copyWith(
      receivedBytes: offset,
      totalBytes: remoteSize,
      etag: remoteEtag,
      isCrypted: isCrypted,
      status: VideoDownloadStatus.downloading,
    );
    hiveService.saveDownload(state);

    final cancelToken = CancelToken();
    _active[key] = cancelToken;

    IOSink? sink;
    try {
      final response = await dio.get<ResponseBody>(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          // Une reprise demande explicitement la suite du fichier.
          headers: offset > 0 ? {HttpHeaders.rangeHeader: 'bytes=$offset-'} : null,
          // Un serveur qui ignore Range répond 200 : il faut pouvoir le détecter.
          validateStatus: (s) => s != null && (s == 200 || s == 206),
        ),
      );

      // 200 sur une reprise = le serveur renvoie tout depuis le début.
      // Ajouter ces octets au fragment le dupliquerait : on repart de zéro.
      final restarted = offset > 0 && response.statusCode == 200;
      if (restarted) {
        loger('[Download] Range ignoré par le serveur — reprise depuis zéro');
        await _deleteQuietly(state.partPath);
        offset = 0;
      }

      final total = _totalFrom(response, offset, remoteSize);

      final file = File(state.partPath);
      await file.parent.create(recursive: true);
      sink = file.openWrite(
        mode: offset > 0 ? FileMode.append : FileMode.write,
      );

      var received = offset;
      var lastPersisted = offset;

      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);

        // La progression n'est écrite qu'au mégaoctet : persister à chaque
        // fragment réseau saturerait le disque sans rien apporter.
        if (received - lastPersisted >= 1024 * 1024) {
          lastPersisted = received;
          state = state.copyWith(receivedBytes: received, totalBytes: total);
          hiveService.saveDownload(state);
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      return _finalize(state, received, total, remoteEtag);

    } on DioException catch (e) {
      await _closeQuietly(sink);
      final received = await _partSize(state.partPath);

      // Annulation ou coupure réseau : le fragment reste, la reprise est possible.
      final resumable = e.type == DioExceptionType.cancel ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout;

      state = state.copyWith(
        receivedBytes: received,
        status: resumable
            ? VideoDownloadStatus.paused
            : VideoDownloadStatus.failed,
      );

      if (!resumable) await _deleteQuietly(state.partPath);
      hiveService.saveDownload(state);
      return state;

    } catch (e) {
      await _closeQuietly(sink);
      loger('[Download] échec pour $coursId : $e');
      // Cause inconnue : on garde le fragment, une reprise reste tentable.
      state = state.copyWith(
        receivedBytes: await _partSize(state.partPath),
        status: VideoDownloadStatus.paused,
      );
      hiveService.saveDownload(state);
      return state;

    } finally {
      _active.remove(key);
      await _closeQuietly(sink);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  /// Renomme le fragment sous son nom définitif et enregistre le cache vidéo.
  Future<VideoDownloadModel> _finalize(
    VideoDownloadModel state,
    int received,
    int total,
    String? etag,
  ) async {
    final part = File(state.partPath);
    if (await part.exists()) {
      final target = File(state.filePath);
      if (await target.exists()) await target.delete();
      await part.rename(state.filePath);
    }

    hiveService.saveVideoCache(
      state.coursId,
      state.matiereId,
      state.filePath,
      state.url,
      isCrypted: state.isCrypted,
    );

    final completed = state.copyWith(
      receivedBytes: received,
      totalBytes: total > 0 ? total : received,
      etag: etag,
      status: VideoDownloadStatus.completed,
    );
    hiveService.saveDownload(completed);
    return completed;
  }

  /// Taille totale attendue, déduite de `Content-Range` si présent.
  int _totalFrom(Response<ResponseBody> response, int offset, int fallback) {
    final contentRange =
        response.headers.value(HttpHeaders.contentRangeHeader);
    if (contentRange != null) {
      final slash = contentRange.lastIndexOf('/');
      if (slash != -1) {
        final parsed = int.tryParse(contentRange.substring(slash + 1));
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    final length = response.headers.value(HttpHeaders.contentLengthHeader);
    final parsed = int.tryParse(length ?? '');
    if (parsed != null && parsed > 0) return offset + parsed;
    return fallback;
  }

  Future<({String finalPath, String partPath})> _resolvePaths(
      String coursId, String? matiereId, String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = '${coursId}_${matiereId ?? 'none'}.${_extensionFromUrl(url)}';
    return (
      finalPath: '${dir.path}/$name',
      partPath: '${dir.path}/$name.part',
    );
  }

  String _extensionFromUrl(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot != -1 && dot < path.length - 1) {
      final ext = path.substring(dot + 1).toLowerCase();
      if (ext.length <= 5) return ext;
    }
    return 'mp4';
  }

  Future<int> _partSize(String path) async {
    try {
      final file = File(path);
      return await file.exists() ? await file.length() : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<void> _closeQuietly(IOSink? sink) async {
    if (sink == null) return;
    try {
      await sink.flush();
      await sink.close();
    } catch (_) {}
  }
}
