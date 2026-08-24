import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/prepa/cours/data/crypto/mxv_container.dart';

/// Serveur HTTP local servant une vidéo chiffrée en clair, à la volée.
///
/// `video_player` ne sait lire qu'un chemin de fichier ou une URL. Écrire la
/// vidéo déchiffrée dans un fichier temporaire laisserait une copie en clair
/// sur l'appareil — exactement ce que le chiffrement cherche à éviter. Le
/// lecteur pointe donc vers `http://127.0.0.1:<port>/…` et les octets sont
/// déchiffrés bloc par bloc au fil de la lecture, uniquement en mémoire.
///
/// Le serveur écoute sur la boucle locale : aucune autre application ne peut
/// l'atteindre depuis le réseau. Un jeton aléatoire dans l'URL empêche en
/// outre une autre application locale de deviner l'adresse.
///
/// Les requêtes `Range` sont gérées : c'est ce qui permet le déplacement dans
/// la vidéo, et cela prépare la reprise de téléchargement à venir.
class EncryptedVideoServer {
  EncryptedVideoServer._(this._server, this._token);

  final HttpServer _server;
  final String _token;

  final Map<String, _Source> _sources = {};

  static EncryptedVideoServer? _instance;

  /// Démarre le serveur au premier usage et le réutilise ensuite.
  static Future<EncryptedVideoServer> instance() async {
    final existing = _instance;
    if (existing != null) return existing;

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final token = _randomToken();
    final created = EncryptedVideoServer._(server, token);
    _instance = created;
    created._listen();
    loger('[VideoServer] démarré sur 127.0.0.1:${server.port}');
    return created;
  }

  /// Publie une vidéo chiffrée et retourne l'URL à donner au lecteur.
  Future<Uri> publish({
    required String id,
    required File encryptedFile,
    required Uint8List key,
  }) async {
    final handle = await encryptedFile.open();
    final header = await MxvHeader.readFrom(handle);

    await _sources[id]?.close();
    _sources[id] = _Source(
      file: handle,
      decryptor: MxvDecryptor(key: key, header: header),
    );

    return Uri.parse('http://127.0.0.1:${_server.port}/$_token/$id');
  }

  /// Libère une vidéo publiée — à appeler à la fermeture du lecteur.
  Future<void> release(String id) async {
    await _sources.remove(id)?.close();
  }

  void _listen() {
    _server.listen((request) async {
      try {
        await _handle(request);
      } catch (e) {
        loger('[VideoServer] erreur : $e');
        try {
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        } catch (_) {}
      }
    });
  }

  Future<void> _handle(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    if (segments.length != 2 || segments[0] != _token) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final source = _sources[segments[1]];
    if (source == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final total = source.decryptor.header.plaintextSize;
    final range = _parseRange(request.headers.value(HttpHeaders.rangeHeader), total);

    final response = request.response;
    response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    response.headers.contentType = ContentType('video', 'mp4');

    if (range == null) {
      response.statusCode = HttpStatus.ok;
      response.headers.set(HttpHeaders.contentLengthHeader, total);
      await _writeRange(response, source, 0, total - 1);
    } else {
      response.statusCode = HttpStatus.partialContent;
      response.headers
        ..set(HttpHeaders.contentRangeHeader,
            'bytes ${range.start}-${range.end}/$total')
        ..set(HttpHeaders.contentLengthHeader, range.end - range.start + 1);
      await _writeRange(response, source, range.start, range.end);
    }

    await response.close();
  }

  /// Écrit une plage d'octets en clair en ne déchiffrant que les blocs qui la
  /// recouvrent — jamais le fichier entier.
  Future<void> _writeRange(
    HttpResponse response,
    _Source source,
    int start,
    int end,
  ) async {
    final header = source.decryptor.header;
    final firstChunk = start ~/ header.chunkSize;
    final lastChunk = end ~/ header.chunkSize;

    for (var index = firstChunk; index <= lastChunk; index++) {
      // Les lectures sont sérialisées : le descripteur de fichier est partagé
      // et son curseur ne supporte pas les accès concurrents.
      final clear = await source.read(index);

      final chunkStart = index * header.chunkSize;
      final from = max(start - chunkStart, 0);
      final to = min(end - chunkStart, clear.length - 1);
      if (to < from) continue;

      response.add(Uint8List.sublistView(clear, from, to + 1));
      await response.flush();
    }
  }

  _Range? _parseRange(String? raw, int total) {
    if (raw == null || !raw.startsWith('bytes=')) return null;
    final spec = raw.substring(6).split('-');
    if (spec.isEmpty) return null;

    final start = int.tryParse(spec[0]) ?? 0;
    final end = (spec.length > 1 && spec[1].isNotEmpty)
        ? (int.tryParse(spec[1]) ?? total - 1)
        : total - 1;

    if (start >= total) return null;
    return _Range(start, min(end, total - 1));
  }

  static String _randomToken() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

class _Range {
  final int start;
  final int end;
  const _Range(this.start, this.end);
}

/// Une vidéo publiée : descripteur ouvert + déchiffreur, avec sérialisation
/// des lectures.
class _Source {
  final RandomAccessFile file;
  final MxvDecryptor decryptor;

  Future<void> _queue = Future.value();

  _Source({required this.file, required this.decryptor});

  Future<Uint8List> read(int index) {
    final completer = Completer<Uint8List>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await decryptor.readChunk(file, index));
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }

  Future<void> close() async {
    try {
      await file.close();
    } catch (_) {}
  }
}
