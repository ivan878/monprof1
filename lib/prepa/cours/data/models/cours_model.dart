import 'package:monprof/prepa/auth/data/services/prepa_api_client.dart';

class PrepaCoursModel {
  final String id;
  final String? title;
  final String? body;
  final String? videoUrl;
  final String? matiereId;
  final bool gratuit;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  final String? userId;

  const PrepaCoursModel({
    required this.id,
    this.title,
    this.body,
    this.videoUrl,
    this.matiereId,
    this.gratuit = false,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'videoUrl': videoUrl,
        'matiereId': matiereId,
        'gratuit': gratuit,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'metadata': metadata,
        'userId': userId,
      };

  factory PrepaCoursModel.fromJson(Map<String, dynamic> json) {
    return PrepaCoursModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      videoUrl: json['videoUrl']
          ?.toString()
          .replaceAll('http://localhost', 'http://$prepaBasePath'),
      matiereId: json['matiereId']?.toString() ??
          (json['matiere'] as Map<String, dynamic>?)?['id']?.toString(),
      gratuit: json['gratuit'] as bool? ?? false,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      userId: json['userId']?.toString(),
    );
  }
}
