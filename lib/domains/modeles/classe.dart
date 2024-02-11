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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
