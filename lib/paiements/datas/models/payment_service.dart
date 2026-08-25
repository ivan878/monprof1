class PaymentService {
  final int id;
  final String title;
  final String? imageUrl;
  final String? description;
  final String subtitle;
  final bool isActive;
  final String phonePattern;
  final String sense;
  final double providerFeePercentage;
  final double userFeePercentage;

  const PaymentService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.phonePattern,
    required this.sense,
    required this.providerFeePercentage,
    required this.userFeePercentage,
    this.imageUrl,
    this.description,
  });

  factory PaymentService.fromMap(Map<String, dynamic> map) {
    return PaymentService(
      id: (map['id'] as num).toInt(),
      title: map['title']?.toString() ?? 'Service de paiement',
      imageUrl: (map['image_url'] ?? map['img'])?.toString(),
      description: map['description']?.toString(),
      subtitle: map['subtitle']?.toString() ?? '',
      isActive: map['is_active'] == true || map['is_active'] == 1,
      phonePattern: map['reg_exp']?.toString() ?? '',
      sense: map['sens']?.toString().toUpperCase() ?? 'IN',
      providerFeePercentage:
          _toDouble(map['provider_fee_percentage'], fallback: 2.5),
      userFeePercentage: _toDouble(map['user_fee_percentage'], fallback: 100),
    );
  }

  int serviceFeeFor(int baseAmount) {
    final providerFee = baseAmount * providerFeePercentage / 100;
    final userFee = providerFee * userFeePercentage.clamp(0, 100) / 100;
    final totalAmount = ((baseAmount + userFee) / 5).ceil() * 5;
    return totalAmount - baseAmount;
  }

  bool acceptsPhoneNumber(String phoneNumber) {
    if (!isActive || sense != 'IN' || phonePattern.isEmpty) {
      return false;
    }

    try {
      return RegExp(phonePattern).hasMatch(phoneNumber);
    } on FormatException {
      return false;
    }
  }

  static double _toDouble(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
