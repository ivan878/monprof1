class Categorie {
  int? id;
  String? description;
  String? libelle;
  DateTime? createdAt;
  DateTime? updatedAt;

  Categorie({
    this.id,
    this.description,
    this.libelle,
    this.createdAt,
    this.updatedAt,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      id: json['id'],
      description: json['description'],
      libelle: json['libelle'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'libelle': libelle,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
