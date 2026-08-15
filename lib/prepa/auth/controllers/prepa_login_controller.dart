import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/auth/data/models/otp_initiate_result.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';

enum LoginIdentifierType { email, phone }

class PrepaLoginController extends ChangeNotifier {
  final PrepaAuthRepository repository;

  PrepaLoginController({required this.repository});

  // ── Formulaire ──────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final contactController = TextEditingController();
  final passwordController = TextEditingController();

  LoginIdentifierType identifierType = LoginIdentifierType.email;
  String _dialCode = '+237';

  // ── États ───────────────────────────────────────────────────────────────────
  AppState<OtpInitiateResult> initiateState = AppState();

  // ── Getters ─────────────────────────────────────────────────────────────────
  bool get isEmail => identifierType == LoginIdentifierType.email;

  String get contact => contactController.text.trim();

  int get password => int.tryParse(passwordController.text.trim()) ?? 0;

  PrepaNotificationType get defaultChannel =>
      isEmail ? PrepaNotificationType.email : PrepaNotificationType.sms;

  // ── Actions ─────────────────────────────────────────────────────────────────
  void setDialCode(String code) => _dialCode = code;

  void switchIdentifierType(LoginIdentifierType type) {
    identifierType = type;
    contactController.clear();
    notifyListeners();
  }

  Future<void> initiateLogin({
    PrepaNotificationType? forceChannel,
  }) async {
    if (!formKey.currentState!.validate()) return;
    initiateState = AppState(status: AppStatus.loading);
    notifyListeners();

    final channel = forceChannel ?? defaultChannel;
    final fullPhone = '$_dialCode${contact.replaceAll(RegExp(r'\s'), '')}';
    initiateState = await repository.initiateLogin(
      email: isEmail ? contact : null,
      phoneNumber: isEmail ? null : fullPhone,
      password: password,
      notificationType: channel,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    contactController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
