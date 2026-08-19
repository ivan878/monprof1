/// Souscription telle que l'API la renvoie au titulaire (`MySubscriptionResponse`).
///
/// Le serveur ne transmet plus `userId`, `isActive` ni `metadata` : ces champs
/// portaient des données internes — dont le code d'activation ayant ouvert
/// l'accès — et n'ont aucun usage côté application.
class SubscriptionModel {
  final String id;
  final String? status;
  final int? count;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Session
  final String? concoursSessionId;
  final String? sessionName;
  final DateTime? sessionStartDate;
  final DateTime? sessionEndDate;
  final String? sessionStatus;
  final double? sessionAmount;

  // Concours
  final String? concoursId;
  final String? concoursName;
  final String? concoursLogoUrl;

  const SubscriptionModel({
    required this.id,
    this.status,
    this.count,
    this.createdAt,
    this.updatedAt,
    this.concoursSessionId,
    this.sessionName,
    this.sessionStartDate,
    this.sessionEndDate,
    this.sessionStatus,
    this.sessionAmount,
    this.concoursId,
    this.concoursName,
    this.concoursLogoUrl,
  });

  bool get isRunning => status?.toUpperCase() == 'RUNNING';

  /// Achat groupé : les places ont été converties en codes partageables.
  bool get isGroupPurchase => (count ?? 1) > 1;

  /// Montant total réglé, quand le prix unitaire est connu.
  double? get totalAmount =>
      sessionAmount == null ? null : sessionAmount! * (count ?? 1);

  /// Jours restants avant la fin de session — négatif si la session est passée.
  int? get daysLeft => sessionEndDate?.difference(DateTime.now()).inDays;

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString());

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString(),
      count: (json['count'] as num?)?.toInt(),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      concoursSessionId: json['concoursSessionId']?.toString(),
      sessionName: json['sessionName']?.toString(),
      sessionStartDate: _date(json['sessionStartDate']),
      sessionEndDate: _date(json['sessionEndDate']),
      sessionStatus: json['sessionStatus']?.toString(),
      sessionAmount: (json['sessionAmount'] as num?)?.toDouble(),
      concoursId: json['concoursId']?.toString(),
      concoursName: json['concoursName']?.toString(),
      concoursLogoUrl: json['concoursLogoUrl']?.toString(),
    );
  }
}
