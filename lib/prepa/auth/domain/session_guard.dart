import 'dart:async';

/// Point de signalement d'une session devenue invalide côté serveur.
///
/// La couche réseau détecte le cas mais n'a pas à connaître la navigation ;
/// la couche présentation écoute et décide quoi faire. Cela évite d'appeler
/// un `Navigator` depuis un intercepteur Dio.
///
/// Aujourd'hui la seule cause est `DEVICE_MISMATCH` : le compte a été
/// réactivé sur un autre appareil, la session locale n'est plus valable.
class SessionGuard {
  SessionGuard._();

  static final SessionGuard instance = SessionGuard._();

  final _controller = StreamController<SessionInvalidation>.broadcast();

  /// Émis une seule fois par invalidation, même si plusieurs requêtes
  /// échouent simultanément.
  Stream<SessionInvalidation> get onInvalidated => _controller.stream;

  bool _signalled = false;

  void signal(SessionInvalidation invalidation) {
    if (_signalled) return;
    _signalled = true;
    _controller.add(invalidation);
  }

  /// À appeler une fois la déconnexion terminée, pour réarmer le garde.
  void reset() => _signalled = false;
}

/// Motif d'invalidation, avec le message serveur destiné à l'utilisateur.
class SessionInvalidation {
  final String code;
  final String message;

  const SessionInvalidation({required this.code, required this.message});

  static const String deviceMismatch = 'DEVICE_MISMATCH';
}
