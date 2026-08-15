/// Résultat de l'initiation OTP (login, register, reset-password).
/// Miroir du champ `data` renvoyé par les endpoints /auth/*/initiate.
class OtpInitiateResult {
  final String otpSessionId;
  final String? email;
  final String? phoneNumber;
  final int? expirationTime;

  const OtpInitiateResult({
    required this.otpSessionId,
    this.email,
    this.phoneNumber,
    this.expirationTime,
  });

  factory OtpInitiateResult.fromJson(Map<String, dynamic> json) {
    return OtpInitiateResult(
      otpSessionId: json['otpId']?.toString() ?? '',
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      expirationTime: json['expirationTime'] as int?,
    );
  }
}
