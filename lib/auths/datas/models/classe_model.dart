class Classe {
  int? id;
  String? libelle;
  String? shortName;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;

  Classe({
    this.id,
    this.libelle,
    this.shortName,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
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
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Méthode pour comparer deux instances Classe
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classe &&
        other.libelle == libelle &&
        other.shortName == shortName &&
        other.description == description &&
        other.id == id;
  }

  // Méthode pour obtenir le hash code de l'instance Classe
  @override
  int get hashCode {
    return libelle.hashCode ^
        shortName.hashCode ^
        description.hashCode ^
        id.hashCode;
  }
}
