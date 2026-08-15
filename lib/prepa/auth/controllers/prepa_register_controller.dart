import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/auth/data/models/otp_initiate_result.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';

enum RegisterContactType { email, phone, both }

class PrepaRegisterController extends ChangeNotifier {
  final PrepaAuthRepository repository;

  PrepaRegisterController({required this.repository});

  // ── Formulaire ──────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  RegisterContactType contactType = RegisterContactType.email;
  String _dialCode = '+237';

  // ── État ────────────────────────────────────────────────────────────────────
  AppState<OtpInitiateResult> initiateState = AppState();

  // ── Getters ─────────────────────────────────────────────────────────────────
  bool get useEmail =>
      contactType == RegisterContactType.email ||
      contactType == RegisterContactType.both;

  bool get usePhone =>
      contactType == RegisterContactType.phone ||
      contactType == RegisterContactType.both;

  PrepaNotificationType get defaultChannel =>
      contactType == RegisterContactType.phone
          ? PrepaNotificationType.sms
          : PrepaNotificationType.email;

  String get email => emailController.text.trim();
  String get phone => phoneController.text.trim();
  String get name => nameController.text.trim();

  int get password => int.tryParse(passwordController.text.trim()) ?? 0;

  // ── Actions ─────────────────────────────────────────────────────────────────
  void setDialCode(String code) => _dialCode = code;

  void switchContactType(RegisterContactType type) {
    contactType = type;
    notifyListeners();
  }

  Future<void> initiateRegister() async {
    if (!formKey.currentState!.validate()) return;
    initiateState = AppState(status: AppStatus.loading);
    notifyListeners();

    final fullPhone = phone.isNotEmpty
        ? '$_dialCode${phone.replaceAll(RegExp(r'\s'), '')}'
        : null;
    initiateState = await repository.initiateRegister(
      fullName: name,
      email: email.isNotEmpty ? email : null,
      phoneNumber: fullPhone,
      notificationType: defaultChannel,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
