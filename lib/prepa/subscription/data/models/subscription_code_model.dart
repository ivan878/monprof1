class SubscriptionCodeModel {
  final String id;
  final String? code;
  final String? subscriptionId;
  final String? status; // ACTIVE | USED | EXPIRED | INVALID
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  // Consommation
  final String? usedByUserId;
  final String? usedByName;
  final String? usedByPhone;
  final DateTime? usedAt;
  final String? activatedSubscriptionId;

  // Acheteur
  final String? buyerId;
  final String? buyerName;
  final String? buyerPhone;

  // Session + concours
  final String? concoursSessionId;
  final String? sessionName;
  final DateTime? sessionStartDate;
  final DateTime? sessionEndDate;
  final double? sessionAmount;
  final String? concoursId;
  final String? concoursName;
  final String? concoursLogoUrl;

  const SubscriptionCodeModel({
    required this.id,
    this.code,
    this.subscriptionId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.usedByUserId,
    this.usedByName,
    this.usedByPhone,
    this.usedAt,
    this.activatedSubscriptionId,
    this.buyerId,
    this.buyerName,
    this.buyerPhone,
    this.concoursSessionId,
    this.sessionName,
    this.sessionStartDate,
    this.sessionEndDate,
    this.sessionAmount,
    this.concoursId,
    this.concoursName,
    this.concoursLogoUrl,
  });

  bool get isUsed => status?.toUpperCase() == 'USED';
  bool get isAvailable => status?.toUpperCase() == 'ACTIVE';

  /// Format lisible pour l'affichage et le partage : XXXX-XXXX.
  String get formatted {
    final raw = code ?? '';
    if (raw.length != 8) return raw;
    return '${raw.substring(0, 4)}-${raw.substring(4)}';
  }

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  factory SubscriptionCodeModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionCodeModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString(),
      subscriptionId: json['subscriptionId']?.toString(),
      status: json['status']?.toString(),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      usedByUserId: json['usedByUserId']?.toString(),
      usedByName: json['usedByName']?.toString(),
      usedByPhone: json['usedByPhone']?.toString(),
      usedAt: _date(json['usedAt']),
      activatedSubscriptionId: json['activatedSubscriptionId']?.toString(),
      buyerId: json['buyerId']?.toString(),
      buyerName: json['buyerName']?.toString(),
      buyerPhone: json['buyerPhone']?.toString(),
      concoursSessionId: json['concoursSessionId']?.toString(),
      sessionName: json['sessionName']?.toString(),
      sessionStartDate: _date(json['sessionStartDate']),
      sessionEndDate: _date(json['sessionEndDate']),
      sessionAmount: (json['sessionAmount'] as num?)?.toDouble(),
      concoursId: json['concoursId']?.toString(),
      concoursName: json['concoursName']?.toString(),
      concoursLogoUrl: json['concoursLogoUrl']?.toString(),
    );
  }
}

/// Codes regroupés par session de concours (écran « Mes codes »).
class SubscriptionCodeGroupModel {
  final String? concoursSessionId;
  final String? sessionName;
  final DateTime? sessionStartDate;
  final DateTime? sessionEndDate;
  final String? concoursId;
  final String? concoursName;
  final String? concoursLogoUrl;
  final int totalCount;
  final int availableCount;
  final int usedCount;
  final List<SubscriptionCodeModel> codes;

  const SubscriptionCodeGroupModel({
    this.concoursSessionId,
    this.sessionName,
    this.sessionStartDate,
    this.sessionEndDate,
    this.concoursId,
    this.concoursName,
    this.concoursLogoUrl,
    this.totalCount = 0,
    this.availableCount = 0,
    this.usedCount = 0,
    this.codes = const [],
  });

  factory SubscriptionCodeGroupModel.fromJson(Map<String, dynamic> json) {
    final rawCodes = json['codes'];
    return SubscriptionCodeGroupModel(
      concoursSessionId: json['concoursSessionId']?.toString(),
      sessionName: json['sessionName']?.toString(),
      sessionStartDate: SubscriptionCodeModel._date(json['sessionStartDate']),
      sessionEndDate: SubscriptionCodeModel._date(json['sessionEndDate']),
      concoursId: json['concoursId']?.toString(),
      concoursName: json['concoursName']?.toString(),
      concoursLogoUrl: json['concoursLogoUrl']?.toString(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      availableCount: (json['availableCount'] as num?)?.toInt() ?? 0,
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      codes: rawCodes is List
          ? rawCodes
              .map((e) =>
                  SubscriptionCodeModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
