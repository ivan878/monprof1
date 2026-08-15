import 'package:monprof/prepa/auth/data/services/prepa_api_client.dart';

class MatiereModel {
  final String id;
  final String? name;
  final String? description;
  final String? logoUrl;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const MatiereModel({
    required this.id,
    this.name,
    this.description,
    this.logoUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'metadata': metadata,
      };

  factory MatiereModel.fromJson(Map<String, dynamic> json) {
    return MatiereModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      logoUrl: json['logoUrl']
          ?.toString()
          .replaceAll('http://localhost', 'http://$prepaBasePath'),
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
