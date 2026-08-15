import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';

const String _prepaUserKey = 'PREPA_USER';

/// Stockage sécurisé du profil utilisateur.
/// Le token d'authentification n'est plus stocké ici :
/// Firebase gère son propre ID Token (renouvellement automatique).
class PrepaTokenStorage {
  final FlutterSecureStorage _storage;

  const PrepaTokenStorage(this._storage);

  Future<PrepaUser?> getUser() async {
    final raw = await _storage.read(key: _prepaUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return PrepaUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> setUser(PrepaUser user) =>
      _storage.write(key: _prepaUserKey, value: user.toJsonString());

  Future<void> clear() => _storage.deleteAll();
}
