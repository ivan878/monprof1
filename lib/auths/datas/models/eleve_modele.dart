import 'package:monprof/corps/utils/helper.dart';

class Eleve {
  Eleve({
    required this.etablissement,
    required this.sexe,
    this.userId,
    this.id,
    this.classeId,
    this.updatedAt,
    this.createdAt,
  });

  // Méthode pour créer une instance Eleve à partir d'un Map JSON
  factory Eleve.fromJson(Map<String, dynamic> json) {
    loger(json);
    return Eleve(
      sexe: json['sexe'],
      etablissement: json['etablissement'],
      classeId: int.parse(json['classe_id'].toString()),
      userId: json['user_id'],
      updatedAt: DateTime.parse(json['updated_at']),
      createdAt: DateTime.parse(json['created_at']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sexe': sexe,
      'etablissement': etablissement,
      'classe_id': classeId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
      'id': id,
    };
  }

  // Méthode pour comparer deux instances Eleve
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Eleve &&
        other.etablissement == etablissement &&
        other.sexe == sexe &&
        other.userId == userId &&
        other.id == id;
  }

  // Méthode pour obtenir le hash code de l'instance Eleve
  @override
  int get hashCode {
    return etablissement.hashCode ^
        sexe.hashCode ^
        userId.hashCode ^
        classeId.hashCode ^
        id.hashCode;
  }

  String etablissement;
  String sexe;
  int? userId;
  int? classeId;
  int? id;
  DateTime? updatedAt;
  DateTime? createdAt;
}
