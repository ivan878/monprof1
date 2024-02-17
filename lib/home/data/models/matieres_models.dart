// ignore_for_file: public_member_api_docs, sort_constructors_first
class Matiere {
  int? id;
  String? libelle;
  String? shortName;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  Matiere({
    this.id,
    this.libelle,
    this.shortName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['id'],
      libelle: json['libelle'],
      shortName: json['short_name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'short_name': shortName,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(covariant Matiere other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.libelle == libelle &&
        other.shortName == shortName &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        libelle.hashCode ^
        shortName.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
