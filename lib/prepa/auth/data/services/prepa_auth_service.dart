import 'package:dio/dio.dart';
import 'package:monprof/prepa/auth/data/models/auth_response.dart';
import 'package:monprof/prepa/auth/data/models/otp_initiate_result.dart';

enum PrepaNotificationType { email, sms, whatsapp }

extension PrepaNotificationTypeExt on PrepaNotificationType {
  String get value => name.toUpperCase();
}

enum PrepaOtpFlow { login, register, resetPassword }

class PrepaAuthService {
  final Dio dio;
  PrepaAuthService({required this.dio});

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<OtpInitiateResult> initiateLogin({
    String? email,
    String? phoneNumber,
    required int password,
    PrepaNotificationType? notificationType,
  }) async {
    final body = <String, dynamic>{'password': password};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }
    if (notificationType != null) {
      body['notificationType'] = notificationType.value;
    }
    final res = await dio.post('/auth/login/initiate', data: body);
    return OtpInitiateResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<AuthResponse> completeLogin({
    required String otpSessionId,
    required int otp,
  }) async {
    final res = await dio.post('/auth/login/complete', data: {
      'otpSessionId': otpSessionId,
      'otp': otp,
    });
    return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── Register ────────────────────────────────────────────────────────────────

  Future<OtpInitiateResult> initiateRegister({
    required String fullName,
    String? email,
    String? phoneNumber,
    PrepaNotificationType? notificationType,
  }) async {
    final body = <String, dynamic>{'fullName': fullName};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }
    if (notificationType != null) {
      body['notificationType'] = notificationType.value;
    }
    final res = await dio.post('/auth/register/initiate', data: body);
    return OtpInitiateResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<AuthResponse> completeRegister({
    required String otpSessionId,
    required int otp,
    required int password,
  }) async {
    final res = await dio.post('/auth/register/complete', data: {
      'otpSessionId': otpSessionId,
      'otp': otp,
      'password': password,
    });
    return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── OTP ─────────────────────────────────────────────────────────────────────

  Future<OtpInitiateResult> resendOtp({
    required String otpSessionId,
    String? type,
  }) async {
    final body = <String, dynamic>{'otpSessionId': otpSessionId};
    if (type != null) body['type'] = type;
    final res = await dio.post('/auth/otp/resend', data: body);
    return OtpInitiateResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── Reset Password ──────────────────────────────────────────────────────────

  Future<OtpInitiateResult> initiateResetPassword({
    String? email,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }
    final res = await dio.post('/auth/reset-password/initiate', data: body);
    return OtpInitiateResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> validateResetPassword({
    required String otpSessionId,
    required String otp,
    required String newPassword,
  }) async {
    await dio.post('/auth/reset-password/validate', data: {
      'otpSessionId': otpSessionId,
      'otp': otp,
      'newPassword': newPassword,
    });
  }
}
