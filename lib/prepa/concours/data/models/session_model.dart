import 'package:monprof/prepa/concours/data/models/matiere_session_model.dart';

class SessionModel {
  final String id;
  final String? concoursId;
  final String? concoursName;
  final String? concoursLogoUrl;
  final String? name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? amount;
  final String? status;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  final List<MatiereSessionModel> matieres;

  const SessionModel({
    required this.id,
    this.concoursId,
    this.concoursName,
    this.concoursLogoUrl,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.amount,
    this.status,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.matieres = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'concoursId': concoursId,
        'concoursName': concoursName,
        'concoursLogoUrl': concoursLogoUrl,
        'name': name,
        'description': description,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'amount': amount,
        'status': status,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'metadata': metadata,
        'matieres': matieres.map((m) => m.toJson()).toList(),
      };

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final concours = json['concours'] as Map<String, dynamic>?;
    final matieresJson = json['matieres'] as List<dynamic>?;

    return SessionModel(
      id: json['id']?.toString() ?? '',
      concoursId: concours?['id']?.toString() ?? json['concoursId']?.toString(),
      concoursName: concours?['name']?.toString() ?? json['concoursName']?.toString(),
      concoursLogoUrl: concours?['logoUrl']?.toString() ?? json['concoursLogoUrl']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      matieres: matieresJson
              ?.map((e) => MatiereSessionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
