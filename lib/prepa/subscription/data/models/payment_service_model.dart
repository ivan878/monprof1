import 'package:monprof/prepa/auth/data/services/prepa_api_client.dart';

class PaymentServiceModel {
  final String id;
  final String? name;
  final String? description;
  final String? logoUrl;
  final String? paymentProviderId;
  final String? sens;
  final String? regExp;
  final double? rate;
  final double? providerRate;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentServiceModel({
    required this.id,
    this.name,
    this.description,
    this.logoUrl,
    this.paymentProviderId,
    this.sens,
    this.regExp,
    this.rate,
    this.providerRate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentServiceModel.fromJson(Map<String, dynamic> json) {
    return PaymentServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      logoUrl: json['logoUrl']
          ?.toString()
          .replaceAll('http://localhost', 'http://$prepaBasePath'),
      paymentProviderId: json['paymentProviderId']?.toString(),
      sens: json['sens']?.toString(),
      regExp: json['regExp']?.toString(),
      rate: (json['rate'] as num?)?.toDouble(),
      providerRate: (json['providerRate'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
