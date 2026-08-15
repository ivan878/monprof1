class SubscriptionModel {
  final String id;
  final String? concoursSessionId;
  final String? userId;
  final int? count;
  final String? status;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  // Champs enrichis (session + concours)
  final String? sessionName;
  final DateTime? sessionStartDate;
  final DateTime? sessionEndDate;
  final String? sessionStatus;
  final double? sessionAmount;
  final String? concoursId;
  final String? concoursName;
  final String? concoursLogoUrl;

  const SubscriptionModel({
    required this.id,
    this.concoursSessionId,
    this.userId,
    this.count,
    this.status,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.sessionName,
    this.sessionStartDate,
    this.sessionEndDate,
    this.sessionStatus,
    this.sessionAmount,
    this.concoursId,
    this.concoursName,
    this.concoursLogoUrl,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id']?.toString() ?? '',
      concoursSessionId: json['concoursSessionId']?.toString(),
      userId: json['userId']?.toString(),
      count: json['count'] as int?,
      status: json['status']?.toString(),
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      sessionName: json['sessionName']?.toString(),
      sessionStartDate: json['sessionStartDate'] != null
          ? DateTime.tryParse(json['sessionStartDate'].toString())
          : null,
      sessionEndDate: json['sessionEndDate'] != null
          ? DateTime.tryParse(json['sessionEndDate'].toString())
          : null,
      sessionStatus: json['sessionStatus']?.toString(),
      sessionAmount: (json['sessionAmount'] as num?)?.toDouble(),
      concoursId: json['concoursId']?.toString(),
      concoursName: json['concoursName']?.toString(),
      concoursLogoUrl: json['concoursLogoUrl']?.toString(),
    );
  }
}
