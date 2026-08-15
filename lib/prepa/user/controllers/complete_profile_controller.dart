import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

class CompleteProfileController extends ChangeNotifier {
  final PrepaUserRepository repository;
  final PrepaUser? initialUser;
  final bool hasPassword;

  CompleteProfileController({
    required this.repository,
    this.initialUser,
    bool? hasPassword,
  }) : hasPassword = hasPassword ?? initialUser?.hasPassword ?? true {
    nameController = TextEditingController(text: initialUser?.name ?? '');
    phoneController = TextEditingController();
  }

  // ── Formulaire ──────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String _dialCode = '+237';
  void setDialCode(String code) => _dialCode = code;

  String? localImagePath;

  // ── États ───────────────────────────────────────────────────────────────────
  AppState<PrepaUser> updateState = AppState();
  AppState<PrepaUser> uploadState = AppState();
  AppState<void> setPasswordState = AppState();

  bool get isSaving =>
      updateState.isLoading ||
      uploadState.isLoading ||
      setPasswordState.isLoading;

  // ── Actions ─────────────────────────────────────────────────────────────────

  void setLocalImage(String path) {
    localImagePath = path;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;
    updateState = AppState(status: AppStatus.loading);
    notifyListeners();

    if (localImagePath != null) {
      uploadState = AppState(status: AppStatus.loading);
      notifyListeners();
      uploadState = await repository.uploadProfilePicture(localImagePath!);
      if (uploadState.hasError) {
        updateState = AppState();
        notifyListeners();
        return;
      }
      notifyListeners();
    }

    final localDigits = phoneController.text.trim().replaceAll(RegExp(r'\s'), '');
    updateState = await repository.updateProfile(
      fullName: nameController.text.trim().isNotEmpty
          ? nameController.text.trim()
          : null,
      phoneNumber: localDigits.isNotEmpty ? '$_dialCode$localDigits' : null,
    );
    if (updateState.hasError) {
      notifyListeners();
      return;
    }

    if (!hasPassword && passwordController.text.trim().isNotEmpty) {
      setPasswordState = AppState(status: AppStatus.loading);
      notifyListeners();
      final pin = int.tryParse(passwordController.text.trim());
      if (pin == null) {
        setPasswordState = AppState(status: AppStatus.error, errorModel: null);
        updateState = AppState();
        notifyListeners();
        return;
      }
      setPasswordState = await repository.setPassword(pin);
      if (setPasswordState.hasError) {
        updateState = AppState(
          status: AppStatus.error,
          errorModel: setPasswordState.errorModel,
        );
        notifyListeners();
        return;
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
