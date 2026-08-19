import 'dart:io' show Platform;

import 'package:monprof/prepa/auth/data/models/prepa_user.dart';

/// Mode restreint iOS.
///
/// Actif uniquement lorsque **les deux** conditions sont réunies : la plateforme
/// est iOS et le compte connecté est celui de revue. Sur Android, ou pour tout
/// autre compte, l'application se comporte normalement.
///
/// Le drapeau est recalculé à chaque fois que l'utilisateur courant est chargé
/// (démarrage, connexion, rafraîchissement du profil) puis lu de façon
/// synchrone par les écrans, qui n'ont ainsi pas à connaître la règle.
class AppleReviewMode {
  AppleReviewMode._();

  static final AppleReviewMode instance = AppleReviewMode._();

  /// Compte pour lequel le mode restreint s'applique.
  static const String reviewEmail = 'engel@rich.dev';

  bool _active = false;

  bool get isActive => _active;

  /// Recalcule le drapeau à partir de l'utilisateur fourni.
  void applyTo(PrepaUser? user) {
    _active = _matches(user);
  }

  void reset() => _active = false;

  bool _matches(PrepaUser? user) {
    if (!_isIOS) return false;
    final email = user?.email?.trim().toLowerCase();
    return email != null && email == reviewEmail;
  }

  /// `Platform` lève sur le web : la vérification est isolée ici.
  bool get _isIOS {
    try {
      return Platform.isIOS;
    } catch (_) {
      return false;
    }
  }
}
