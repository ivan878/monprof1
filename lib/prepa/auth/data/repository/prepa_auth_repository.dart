import 'package:firebase_auth/firebase_auth.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/local_storage/app_storage_cleaner.dart';
import 'package:monprof/prepa/auth/data/models/auth_response.dart';
import 'package:monprof/prepa/auth/data/models/otp_initiate_result.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/common/apple_review_mode.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';
import 'package:monprof/prepa/auth/data/services/prepa_oauth_service.dart';
import 'package:monprof/prepa/auth/data/services/prepa_token_storage.dart';

class PrepaAuthRepository {
  final PrepaAuthService service;
  final PrepaOAuthService? oAuthService;
  final PrepaTokenStorage tokenStorage;
  final AppStorageCleaner? storageCleaner;

  const PrepaAuthRepository({
    required this.service,
    required this.tokenStorage,
    this.oAuthService,
    this.storageCleaner,
  });

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<AppState<OtpInitiateResult>> initiateLogin({
    String? email,
    String? phoneNumber,
    required int password,
    PrepaNotificationType? notificationType,
  }) async {
    try {
      final result = await service.initiateLogin(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        notificationType: notificationType,
      );
      return AppState(status: AppStatus.data, data: result);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaUser>> completeLogin({
    required String otpSessionId,
    required int otp,
  }) async {
    try {
      final authResponse = await service.completeLogin(
        otpSessionId: otpSessionId,
        otp: otp,
      );
      final user = await _handleOtpAuthResponse(authResponse);
      return AppState(status: AppStatus.data, data: user);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── Register ────────────────────────────────────────────────────────────────

  Future<AppState<OtpInitiateResult>> initiateRegister({
    required String fullName,
    String? email,
    String? phoneNumber,
    PrepaNotificationType? notificationType,
  }) async {
    try {
      final result = await service.initiateRegister(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        notificationType: notificationType,
      );
      return AppState(status: AppStatus.data, data: result);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaUser>> completeRegister({
    required String otpSessionId,
    required int otp,
    required int password,
  }) async {
    try {
      final authResponse = await service.completeRegister(
        otpSessionId: otpSessionId,
        otp: otp,
        password: password,
      );
      final user = await _handleOtpAuthResponse(authResponse);
      return AppState(status: AppStatus.data, data: user);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── OTP ─────────────────────────────────────────────────────────────────────

  Future<AppState<OtpInitiateResult>> resendOtp({
    required String otpSessionId,
    String? type,
  }) async {
    try {
      final result = await service.resendOtp(
        otpSessionId: otpSessionId,
        type: type,
      );
      return AppState(status: AppStatus.data, data: result);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── Reset Password ──────────────────────────────────────────────────────────

  Future<AppState<OtpInitiateResult>> initiateResetPassword({
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final result = await service.initiateResetPassword(
        email: email,
        phoneNumber: phoneNumber,
      );
      return AppState(status: AppStatus.data, data: result);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<void>> validateResetPassword({
    required String otpSessionId,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await service.validateResetPassword(
        otpSessionId: otpSessionId,
        otp: otp,
        newPassword: newPassword,
      );
      return AppState(status: AppStatus.data);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── Social (Google / Apple) ─────────────────────────────────────────────────

  Future<AppState<PrepaUser>> signInWithGoogle() async {
    try {
      final authResponse = await oAuthService!.signInWithGoogle();
      // L'utilisateur est déjà connecté Firebase via signInWithCredential.
      // On stocke juste le profil retourné par le backend.
      loger('signInWithGoogle: authResponse: ${authResponse.toString()}');
      final user = await _storeUser(authResponse);
      return AppState(status: AppStatus.data, data: user);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaUser>> signInWithApple() async {
    try {
      final authResponse = await oAuthService!.signInWithApple();
      final user = await _storeUser(authResponse);
      return AppState(status: AppStatus.data, data: user);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── Local storage ───────────────────────────────────────────────────────────

  Future<PrepaUser?> getCachedUser() => tokenStorage.getUser();

  /// Met à jour le profil servant à l'ouverture hors ligne de l'application.
  Future<void> cacheUser(PrepaUser user) => tokenStorage.setUser(user);

  /// Ferme la session et efface toute trace locale du compte :
  /// caches métier, vidéos téléchargées, préférences et stockage sécurisé.
  /// Chaque étape est isolée pour qu'un échec n'empêche pas la déconnexion.
  Future<void> logout() async {
    try {
      await oAuthService?.signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    try {
      await storageCleaner?.clearAll();
    } catch (_) {}
    // Filet de sécurité si le cleaner est absent ou a échoué sur cette étape.
    try {
      await tokenStorage.clear();
    } catch (_) {}
    // Le mode restreint est lié au compte : il ne doit pas survivre à la session.
    AppleReviewMode.instance.reset();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Flux OTP (login / register) :
  /// 1. signInWithCustomToken → Firebase crée la session locale
  /// 2. Stocke le profil utilisateur en local
  Future<PrepaUser> _handleOtpAuthResponse(AuthResponse authResponse) async {
    if (authResponse.token.isNotEmpty) {
      await FirebaseAuth.instance.signInWithCustomToken(authResponse.token);
    }
    return _storeAuthResponseUser(authResponse);
  }

  Future<PrepaUser> _storeAuthResponseUser(AuthResponse authResponse) async {
    final user = authResponse.userResponse!.toPrepaUser();
    await tokenStorage.setUser(user);
    return user;
  }

  Future<PrepaUser> _storeUser(UserResponse authResponse) async {
    final user = authResponse.toPrepaUser();
    await tokenStorage.setUser(user);
    return user;
  }
}
