import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

enum SplashDestination {
  login,
  home,
  completeProfile,
  connectionRequired,
}

class SplashOpenResult {
  final SplashDestination destination;
  final PrepaUser? user;
  final String? message;

  const SplashOpenResult._({
    required this.destination,
    this.user,
    this.message,
  });

  const SplashOpenResult.login() : this._(destination: SplashDestination.login);

  const SplashOpenResult.home({required PrepaUser user})
      : this._(destination: SplashDestination.home, user: user);

  const SplashOpenResult.completeProfile({required PrepaUser user})
      : this._(
          destination: SplashDestination.completeProfile,
          user: user,
        );

  const SplashOpenResult.connectionRequired({String? message})
      : this._(
          destination: SplashDestination.connectionRequired,
          message: message,
        );
}

/// Décide de l'ouverture de l'application sans dépendre de l'interface.
///
/// Une session Firebase et un profil local suffisent pour entrer hors ligne.
/// Le serveur est ensuite interrogé en arrière-plan. Une erreur réseau ne
/// détruit jamais la session locale ; seul un rejet d'authentification le fait.
class SplashController {
  final PrepaAuthRepository authRepository;
  final PrepaUserRepository userRepository;
  final FirebaseAuth _firebaseAuth;

  SplashController({
    required this.authRepository,
    required this.userRepository,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<SplashOpenResult> openApp() async {
    try {
      // Le premier événement est émis après restauration de la session locale
      // Firebase. Il évite de lire currentUser pendant son initialisation.
      final firebaseUser = await _firebaseAuth.authStateChanges().first;

      if (firebaseUser == null) {
        return const SplashOpenResult.login();
      }

      final cachedUser = await authRepository.getCachedUser();

      if (cachedUser != null) {
        if (!_belongsTo(cachedUser, firebaseUser.uid)) {
          // Le cache appartient à un autre compte : il ne doit jamais être
          // présenté à l'utilisateur Firebase actuellement connecté.
          await authRepository.logout();
          return const SplashOpenResult.login();
        }

        // Cache d'abord : l'ouverture ne dépend pas du réseau. La validation
        // distante mettra le profil local à jour sans bloquer l'interface.
        unawaited(_refreshSession());
        return _destinationFor(cachedUser);
      }

      // Première ouverture authentifiée sur cet appareil : aucun profil local
      // ne permet encore d'ouvrir l'application sans le serveur.
      final remoteState = await userRepository.getMe();

      if (remoteState.hasData && remoteState.data != null) {
        final user = remoteState.data!;
        await authRepository.cacheUser(user);
        return _destinationFor(user);
      }

      if (_isUnauthorized(remoteState.errorModel?.code)) {
        // L'intercepteur HTTP signale déjà l'invalidation à SessionGuard, qui
        // centralise la déconnexion et la purge au niveau de PrepaApp.
        return const SplashOpenResult.login();
      }

      return SplashOpenResult.connectionRequired(
        message: remoteState.errorModel?.error,
      );
    } on FirebaseAuthException catch (error) {
      if (_isInvalidFirebaseSession(error.code)) {
        await authRepository.logout();
        return const SplashOpenResult.login();
      }

      return const SplashOpenResult.connectionRequired();
    } catch (_) {
      // Une exception inconnue au démarrage ne constitue pas une preuve que
      // les identifiants sont invalides. On conserve donc toutes les données.
      return const SplashOpenResult.connectionRequired();
    }
  }

  Future<void> _refreshSession() async {
    try {
      final remoteState = await userRepository.getMe();

      if (remoteState.hasData && remoteState.data != null) {
        await authRepository.cacheUser(remoteState.data!);
        return;
      }
    } catch (_) {
      // L'actualisation est volontairement non bloquante : ni le réseau ni
      // l'écriture locale ne doivent interrompre une ouverture depuis le cache.
    }
    // Erreur réseau, timeout ou serveur indisponible : le cache reste valide.
  }

  SplashOpenResult _destinationFor(PrepaUser user) {
    if (!user.hasProfileCompleted || !user.hasPassword) {
      return SplashOpenResult.completeProfile(user: user);
    }
    return SplashOpenResult.home(user: user);
  }

  bool _belongsTo(PrepaUser user, String firebaseUid) {
    final cachedUid = user.firebaseUid;
    // Compatibilité avec les anciens profils enregistrés avant firebaseUid.
    return cachedUid == null || cachedUid.isEmpty || cachedUid == firebaseUid;
  }

  bool _isUnauthorized(int? statusCode) => statusCode == 401;

  bool _isInvalidFirebaseSession(String code) {
    return code == 'user-disabled' ||
        code == 'user-not-found' ||
        code == 'invalid-user-token' ||
        code == 'user-token-expired';
  }
}
