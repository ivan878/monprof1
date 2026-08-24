import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/prepa/cours/data/crypto/mxv_container.dart';
import 'package:monprof/prepa/cours/data/services/cours_service.dart';

/// Clé de contenu d'une vidéo, telle que conservée localement.
class VideoContentKey {
  final String keyId;
  final Uint8List key;

  const VideoContentKey({required this.keyId, required this.key});
}

/// Clés de déchiffrement des vidéos.
///
/// La clé est récupérée auprès du serveur **au téléchargement**, puis conservée
/// dans le coffre sécurisé de l'appareil (Keychain iOS / Keystore Android).
/// C'est ce qui rend la lecture hors connexion possible : la récupérer
/// seulement au moment de lire rendrait toute vidéo téléchargée inutilisable
/// dès la perte du réseau.
///
/// Aucune clé n'est embarquée dans l'application : une valeur codée en dur
/// serait extractible du binaire et compromettrait tout le catalogue. La clé
/// maîtresse du serveur, elle, n'est jamais transmise — le mobile ne reçoit que
/// la clé de la vidéo à laquelle il a droit.
class VideoKeyRepository {
  final PrepaCoursService service;
  final FlutterSecureStorage secureStorage;

  const VideoKeyRepository({
    required this.service,
    required this.secureStorage,
  });

  static const String _prefix = 'VIDEO_KEY_';

  String _storageKey(String coursId) => '$_prefix$coursId';

  /// Clé du cours, depuis le coffre si possible, sinon depuis le serveur.
  ///
  /// [expectedKeyId] : identifiant lu dans l'en-tête du conteneur. S'il ne
  /// correspond pas à la clé en coffre — cas d'une vidéo re-chiffrée côté
  /// administration — la clé locale est périmée et une nouvelle est demandée.
  Future<AppState<VideoContentKey>> resolve(
    String coursId, {
    String? expectedKeyId,
  }) async {
    final cached = await _readCached(coursId);

    if (cached != null) {
      final matches = expectedKeyId == null || cached.keyId == expectedKeyId;
      if (matches) {
        return AppState(status: AppStatus.data, data: cached);
      }
      loger('[VideoKey] clé locale périmée pour $coursId '
          '(${cached.keyId} ≠ $expectedKeyId) — renouvellement');
    }

    return fetchAndStore(coursId);
  }

  /// Récupère la clé auprès du serveur et la met en coffre.
  ///
  /// Appelé au téléchargement : à partir de là, la vidéo est lisible sans
  /// réseau. Nécessite une connexion et un accès actif au cours.
  Future<AppState<VideoContentKey>> fetchAndStore(String coursId) async {
    try {
      final data = await service.getVideoKey(coursId);
      final encoded = data['key']?.toString();
      final keyId = data['keyId']?.toString();

      if (encoded == null || encoded.isEmpty || keyId == null) {
        return AppState(
          status: AppStatus.error,
          errorModel: returnError('Réponse de clé incomplète'),
        );
      }

      await secureStorage.write(
        key: _storageKey(coursId),
        value: jsonEncode({'keyId': keyId, 'key': encoded}),
      );

      return AppState(
        status: AppStatus.data,
        data: VideoContentKey(
          keyId: keyId,
          key: MxvDecryptor.keyFromBase64(encoded),
        ),
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  /// Vrai si la clé du cours est déjà disponible localement.
  Future<bool> hasKey(String coursId) async =>
      (await _readCached(coursId)) != null;

  Future<VideoContentKey?> _readCached(String coursId) async {
    try {
      final raw = await secureStorage.read(key: _storageKey(coursId));
      if (raw == null || raw.isEmpty) return null;

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final encoded = map['key']?.toString();
      final keyId = map['keyId']?.toString();
      if (encoded == null || keyId == null) return null;

      return VideoContentKey(
        keyId: keyId,
        key: MxvDecryptor.keyFromBase64(encoded),
      );
    } catch (e) {
      loger('[VideoKey] lecture du coffre impossible : $e');
      return null;
    }
  }

  /// Oublie la clé d'un cours — après suppression de la vidéo locale.
  Future<void> forget(String coursId) async {
    try {
      await secureStorage.delete(key: _storageKey(coursId));
    } catch (_) {}
  }
}
