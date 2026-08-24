import 'dart:io' show Platform;

import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:monprof/corps/utils/helper.dart';

/// Identité de l'appareil envoyée à chaque requête.
///
/// Le backend s'en sert pour n'autoriser qu'un appareil actif par compte.
/// L'identifiant est résolu une seule fois puis conservé en mémoire : le lire
/// à chaque requête déclencherait un appel de canal natif par appel réseau.
///
/// Volontairement non persisté : la valeur est déjà stable pour la durée de
/// l'installation (identifierForVendor sur iOS, ANDROID_ID sur Android).
/// La stocker dans le coffre sécurisé la ferait disparaître à la déconnexion,
/// qui vide tout le stockage local — or l'identité de l'appareil ne dépend
/// pas de la session.
class DeviceIdentity {
  DeviceIdentity._();

  static final DeviceIdentity instance = DeviceIdentity._();

  /// En-têtes attendus par le backend.
  static const String headerName = 'X-Device-Id';
  static const String platformHeaderName = 'X-Device-Platform';

  Future<String?>? _resolution;
  String? _cached;

  /// Dernière valeur connue, sans déclencher de résolution.
  String? get current => _cached;

  /// Valeur envoyée dans `X-Device-Platform`.
  /// Doit correspondre exactement à l'enum `DevicePlatform` côté backend.
  String get platform {
    try {
      if (Platform.isIOS) return 'IOS';
      if (Platform.isAndroid) return 'ANDROID';
    } catch (_) {
      // `Platform` lève sur le web
    }
    return 'WEB';
  }

  /// Résout l'identifiant. Les appels concurrents partagent la même résolution.
  Future<String?> resolve() => _resolution ??= _read();

  /// À appeler au démarrage pour que la première requête ne paie pas
  /// la latence du canal natif.
  Future<void> warmUp() async {
    await resolve();
  }

  Future<String?> _read() async {
    try {
      final id = await MobileDeviceIdentifier().getDeviceId();
      final trimmed = id?.trim();
      _cached = (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
      if (_cached == null) {
        loger('[DeviceIdentity] identifiant indisponible sur cette plateforme');
      }
      return _cached;
    } catch (e) {
      loger('[DeviceIdentity] échec de résolution : $e');
      // Nouvelle tentative au prochain appel plutôt qu'un échec définitif.
      _resolution = null;
      return null;
    }
  }
}
