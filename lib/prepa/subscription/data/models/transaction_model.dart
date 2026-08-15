class TransactionModel {
  final String id;
  final String? reference;
  final double? amount;
  final String? subscriptionId;
  final String? userId;
  final String? paymentServiceId;
  final String? status;
  final String? sens;
  final String? raisonReject;
  final String? payToken;
  final String? externalId;
  final String? phoneNumber;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const TransactionModel({
    required this.id,
    this.reference,
    this.amount,
    this.subscriptionId,
    this.userId,
    this.paymentServiceId,
    this.status,
    this.sens,
    this.raisonReject,
    this.payToken,
    this.externalId,
    this.phoneNumber,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      subscriptionId: json['subscriptionId']?.toString(),
      userId: json['userId']?.toString(),
      paymentServiceId: json['paymentServiceId']?.toString(),
      status: json['status']?.toString(),
      sens: json['sens']?.toString(),
      raisonReject: json['raisonReject']?.toString(),
      payToken: json['payToken']?.toString(),
      externalId: json['externalId']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
