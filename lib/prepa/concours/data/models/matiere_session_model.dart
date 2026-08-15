import 'package:monprof/prepa/auth/data/services/prepa_api_client.dart';

class MatiereSessionModel {
  final String id;
  final String? name;
  final String? logoUrl;
  final int? dureeMinutes;
  final double? coefficient;

  const MatiereSessionModel({
    required this.id,
    this.name,
    this.logoUrl,
    this.dureeMinutes,
    this.coefficient,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'dureeMinutes': dureeMinutes,
        'coefficient': coefficient,
      };

  factory MatiereSessionModel.fromJson(Map<String, dynamic> json) {
    return MatiereSessionModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      logoUrl: json['logoUrl']
          ?.toString()
          .replaceAll('http://localhost', 'http://$prepaBasePath'),
      dureeMinutes: json['dureeMinutes'] as int?,
      coefficient: (json['coefficient'] as num?)?.toDouble(),
    );
  }
}
