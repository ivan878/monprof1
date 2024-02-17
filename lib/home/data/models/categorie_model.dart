import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  @override
  bool operator ==(covariant Categorie other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.description == description &&
        other.libelle == libelle &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        libelle.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

class CategorieStatus {
  Categorie categorie;
  bool status;
  CategorieStatus({
    required this.categorie,
    required this.status,
  });

  factory CategorieStatus.fromJson(Map<String, dynamic> map) {
    return CategorieStatus(
      categorie: Categorie.fromJson(map['categorie'] as Map<String, dynamic>),
      status: map['status'] as bool,
    );
  }

  @override
  bool operator ==(covariant CategorieStatus other) {
    if (identical(this, other)) return true;

    return other.categorie == categorie && other.status == status;
  }

  @override
  int get hashCode => categorie.hashCode ^ status.hashCode;
}
