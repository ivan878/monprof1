import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/auth/data/models/otp_initiate_result.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';

class PrepaOtpController extends ChangeNotifier {
  final PrepaAuthRepository repository;

  PrepaOtpController({required this.repository});

  // ── Paramètres reçus ────────────────────────────────────────────────────────
  String otpSessionId = '';
  String? email;
  String? phoneNumber;
  PrepaNotificationType currentChannel = PrepaNotificationType.email;
  PrepaOtpFlow flow = PrepaOtpFlow.login;
  int? _registerPassword;

  // ── Formulaire ──────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  // ── États ───────────────────────────────────────────────────────────────────
  AppState<PrepaUser> validateState = AppState();
  AppState<OtpInitiateResult> resendState = AppState();
  bool isSwitchingChannel = false;

  // ── Countdown ───────────────────────────────────────────────────────────────
  static const int _countdownSeconds = 60 * 3;
  int remainingSeconds = _countdownSeconds;
  Timer? _timer;

  bool get canResend => remainingSeconds == 0;

  // ── Init ────────────────────────────────────────────────────────────────────
  void initialize({
    required String otpSessionId,
    String? email,
    String? phoneNumber,
    String? phone,
    required PrepaNotificationType currentChannel,
    required PrepaOtpFlow flow,
    int? registerPassword,
  }) {
    this.otpSessionId = otpSessionId;
    this.email = email;
    this.phoneNumber = phoneNumber ?? phone;
    this.currentChannel = currentChannel;
    this.flow = flow;
    _registerPassword = registerPassword;
    _startCountdown();
    notifyListeners();
  }

  void _startCountdown() {
    _timer?.cancel();
    remainingSeconds = _countdownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        t.cancel();
      }
    });
  }

  // ── Validation OTP ──────────────────────────────────────────────────────────
  Future<void> validateOtp() async {
    if (!formKey.currentState!.validate()) return;
    validateState = AppState(status: AppStatus.loading);
    notifyListeners();

    final otp = int.tryParse(otpController.text.trim()) ?? 0;

    if (flow == PrepaOtpFlow.login) {
      validateState = await repository.completeLogin(
        otpSessionId: otpSessionId,
        otp: otp,
      );
    } else if (flow == PrepaOtpFlow.register) {
      validateState = await repository.completeRegister(
        otpSessionId: otpSessionId,
        otp: otp,
        password: _registerPassword ?? 0,
      );
    }
    notifyListeners();
  }

  // ── Renvoyer OTP ────────────────────────────────────────────────────────────
  Future<void> resendOtp() async {
    if (!canResend) return;
    resendState = AppState(status: AppStatus.loading);
    notifyListeners();

    resendState = await repository.resendOtp(
        otpSessionId: otpSessionId, type: currentChannel.value);
    if (resendState.hasData) {
      otpSessionId = resendState.data!.otpSessionId;
      _startCountdown();
    }
    notifyListeners();
  }

  // ── Changer de canal ────────────────────────────────────────────────────────
  Future<void> switchChannel(PrepaNotificationType newChannel) async {
    if (newChannel == currentChannel) return;
    isSwitchingChannel = true;
    resendState = AppState(status: AppStatus.loading);
    notifyListeners();

    final result = await repository.resendOtp(
      otpSessionId: otpSessionId,
      type: newChannel.value,
    );

    if (result.hasData) {
      otpSessionId = result.data!.otpSessionId;
      currentChannel = newChannel;
      otpController.clear();
      _startCountdown();
      resendState = AppState();
    } else {
      resendState = result;
    }

    isSwitchingChannel = false;
    notifyListeners();
  }

  // ── Clavier personnalisé ────────────────────────────────────────────────────
  void appendDigit(String digit) {
    final current = otpController.text;
    if (current.length < 6) {
      otpController.text = current + digit;
      notifyListeners();
    }
  }

  void deleteDigit() {
    final current = otpController.text;
    if (current.isNotEmpty) {
      otpController.text = current.substring(0, current.length - 1);
      notifyListeners();
    }
  }

  // ── Countdown format ────────────────────────────────────────────────────────
  String get countdownDisplay {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }
}
