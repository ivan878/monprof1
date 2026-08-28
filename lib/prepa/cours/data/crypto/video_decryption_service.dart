import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/prepa/cours/data/crypto/mxv_container.dart';
import 'package:path_provider/path_provider.dart';

/// Déchiffrement complet d'une vidéo avant lecture.
///
/// Le déchiffrement à la volée pendant la lecture s'est révélé inexploitable :
/// saccadé sur iOS, inopérant sur Android, et chaque déplacement dans la vidéo
/// imposait de redéchiffrer depuis le bloc visé. Le fichier est donc déchiffré
/// intégralement en amont, puis lu comme un fichier ordinaire — le lecteur
/// natif retrouve ses performances et le déplacement devient instantané.
///
/// Le travail se fait dans un isolate : déchiffrer plusieurs centaines de
/// mégaoctets sur l'isolate principal figerait l'interface pendant toute
/// l'opération, barre de progression comprise.
///
/// Le fichier en clair est écrit dans le répertoire temporaire, jamais dans les
/// documents : il est supprimé à la fermeture du lecteur, et le système peut
/// le récupérer de lui-même si l'espace vient à manquer.
class VideoDecryptionService {
  VideoDecryptionService._();

  static final VideoDecryptionService instance = VideoDecryptionService._();

  static const String _tempPrefix = 'mxv_clear_';

  /// Déchiffre [encryptedPath] et renvoie le chemin du fichier en clair.
  ///
  /// [onProgress] reçoit une valeur entre 0 et 1.
  /// [cancelled] est consulté régulièrement : s'il devient vrai, l'opération
  /// s'arrête et le fichier partiel est supprimé.
  Future<String> decryptToTemp({
    required String encryptedPath,
    required Uint8List key,
    required String cacheKey,
    void Function(double progress)? onProgress,
    bool Function()? cancelled,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/$_tempPrefix$cacheKey.mp4';

    // Un déchiffrement précédent a pu laisser un fichier complet exploitable.
    final existing = File(outputPath);
    if (await existing.exists()) {
      final header = await _readHeader(encryptedPath);
      if (await existing.length() == header.plaintextSize) {
        onProgress?.call(1);
        return outputPath;
      }
      // Taille incohérente : reste d'une tentative interrompue.
      await existing.delete();
    }

    final receivePort = ReceivePort();
    final completer = Completer<String>();

    final isolate = await Isolate.spawn(
      _decryptEntryPoint,
      _DecryptRequest(
        sendPort: receivePort.sendPort,
        encryptedPath: encryptedPath,
        outputPath: outputPath,
        key: key,
      ),
    );

    late StreamSubscription sub;
    sub = receivePort.listen((message) async {
      if (message is double) {
        onProgress?.call(message);
        if (cancelled?.call() ?? false) {
          isolate.kill(priority: Isolate.immediate);
          await sub.cancel();
          receivePort.close();
          await _deleteQuietly(outputPath);
          if (!completer.isCompleted) {
            completer.completeError(
                const _DecryptionCancelled('Déchiffrement annulé'));
          }
        }
      } else if (message is _DecryptDone) {
        await sub.cancel();
        receivePort.close();
        if (!completer.isCompleted) completer.complete(outputPath);
      } else if (message is _DecryptError) {
        await sub.cancel();
        receivePort.close();
        await _deleteQuietly(outputPath);
        if (!completer.isCompleted) {
          completer.completeError(StateError(message.message));
        }
      }
    });

    return completer.future;
  }

  /// Supprime la copie en clair d'une vidéo.
  Future<void> discard(String cacheKey) async {
    try {
      final tempDir = await getTemporaryDirectory();
      await _deleteQuietly('${tempDir.path}/$_tempPrefix$cacheKey.mp4');
    } catch (_) {}
  }

  /// Supprime toutes les copies en clair laissées par des sessions passées.
  ///
  /// Appelé au démarrage : une fermeture brutale de l'application peut laisser
  /// un fichier en clair derrière elle, qu'il ne faut pas conserver.
  Future<void> purgeAll() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (!await tempDir.exists()) return;
      await for (final entity in tempDir.list(followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.path.split(Platform.pathSeparator).last;
        if (name.startsWith(_tempPrefix)) {
          await _deleteQuietly(entity.path);
        }
      }
    } catch (e) {
      loger('[Decrypt] purge des copies en clair impossible : $e');
    }
  }

  Future<MxvHeader> _readHeader(String path) async {
    final handle = await File(path).open();
    try {
      return await MxvHeader.readFrom(handle);
    } finally {
      await handle.close();
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}

/// Annulation demandée par l'utilisateur — distincte d'une véritable erreur.
class _DecryptionCancelled implements Exception {
  final String message;
  const _DecryptionCancelled(this.message);
  @override
  String toString() => message;
}

// ── Communication avec l'isolate ─────────────────────────────────────────────

class _DecryptRequest {
  final SendPort sendPort;
  final String encryptedPath;
  final String outputPath;
  final Uint8List key;

  const _DecryptRequest({
    required this.sendPort,
    required this.encryptedPath,
    required this.outputPath,
    required this.key,
  });
}

class _DecryptDone {
  const _DecryptDone();
}

class _DecryptError {
  final String message;
  const _DecryptError(this.message);
}

/// Point d'entrée de l'isolate : lit bloc par bloc, déchiffre, écrit.
///
/// La mémoire reste bornée à un bloc — un fichier de plusieurs gigaoctets ne
/// pose donc pas de problème.
Future<void> _decryptEntryPoint(_DecryptRequest request) async {
  RandomAccessFile? input;
  IOSink? output;
  try {
    final file = File(request.encryptedPath);
    input = await file.open();
    final header = await MxvHeader.readFrom(input);
    final decryptor = MxvDecryptor(key: request.key, header: header);

    final outFile = File(request.outputPath);
    await outFile.parent.create(recursive: true);
    output = outFile.openWrite();

    final total = header.chunkCount;
    for (var index = 0; index < total; index++) {
      final clear = await decryptor.readChunk(input, index);
      output.add(clear);

      // Une notification par bloc suffit : à 1 Mio par bloc, cela donne une
      // progression fluide sans saturer le port de communication.
      request.sendPort.send((index + 1) / total);
    }

    await output.flush();
    await output.close();
    output = null;

    request.sendPort.send(const _DecryptDone());
  } catch (e) {
    request.sendPort.send(_DecryptError(e.toString()));
  } finally {
    try {
      await input?.close();
    } catch (_) {}
    try {
      await output?.close();
    } catch (_) {}
  }
}
