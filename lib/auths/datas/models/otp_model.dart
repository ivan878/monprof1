class OtpModel {
  String? phone;
  String? otp;
  String? verificationId;
  bool isUsed;

  OtpModel({
    this.phone,
    this.otp,
    this.verificationId,
    this.isUsed = false,
  });

  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      phone: json['phone'],
      otp: json['otp'],
      verificationId: json['verification_id'],
      isUsed: json['is_used'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'otp': otp,
      'verification_id': verificationId,
      'is_used': isUsed,
    };
  }
}
