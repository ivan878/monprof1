import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monprof/corps/utils/constantes.dart';
import 'package:monprof/corps/utils/helper.dart' as Utils;
import 'package:monprof/prepa/auth/data/models/auth_response.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Authentification sociale (Google / Apple) via Firebase.
/// L'utilisateur se connecte Firebase côté client, puis on notifie le backend
/// avec l'ID Token Firebase pour créer / retrouver le compte.
class PrepaOAuthService {
  final Dio dio;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// `initialize()` n'est à appeler qu'une fois par cycle de vie ; le résultat
  /// est mémorisé pour que connexion et déconnexion partagent la même init.
  static Future<void>? _initialization;

  PrepaOAuthService({required this.dio});

  /// Android (google_sign_in 7.x) passe par Credential Manager, qui refuse de
  /// délivrer un idToken sans `serverClientId` — d'où le passage explicite.
  static Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize(
      serverClientId: googleServerClientId,
    );
  }

  // ── Google ─────────────────────────────────────────────────────────────────

  Future<AuthResponse> signInWithGoogle() async {
    await _ensureInitialized();

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final fbUser = userCredential.user;
      if (fbUser != null) {
        if (fbUser.displayName == null || fbUser.displayName!.isEmpty) {
          await fbUser.updateDisplayName(googleUser.displayName);
        }
        if (fbUser.photoURL == null && googleUser.photoUrl != null) {
          await fbUser.updatePhotoURL(googleUser.photoUrl);
        }
      }

      final idToken = await userCredential.user!.getIdToken();
      return _notifyBackend(idToken!);
    } catch (e) {
      Utils.loger('[PrepaOAuthService] signInWithGoogle error: $e');
      rethrow;
    }
  }

  // ── Apple ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    final idToken = await userCredential.user!.getIdToken();
    return _notifyBackend(idToken!);
  }

  /// Envoie l'ID Token Firebase au backend pour créer / retrouver le compte.
  /// Le backend renvoie un AuthResponse (userResponse + token optionnel).
  Future<AuthResponse> _notifyBackend(String idToken) async {
    final res = await dio.post(
      '/auth/login/oauth2',
      data: {'idToken': idToken},
    );
    return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── Déconnexion ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
