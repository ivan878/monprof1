import 'dart:convert';
// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names

class Cours {
  int id;
  String video_url;
  String libelle;
  String description;
  int classe_id;
  int matieres_id;
  int categorie_id;

  String created_at;
  String updated_at;
  bool open;
  Cours({
    required this.id,
    required this.video_url,
    required this.libelle,
    required this.description,
    required this.classe_id,
    required this.matieres_id,
    required this.categorie_id,
    required this.created_at,
    required this.updated_at,
    required this.open,
  });

  Cours copyWith({
    int? id,
    String? video_url,
    String? libelle,
    String? description,
    int? classe_id,
    int? matieres_id,
    int? categorie_id,
    String? created_at,
    String? updated_at,
    bool? open,
  }) {
    return Cours(
      id: id ?? this.id,
      video_url: video_url ?? this.video_url,
      libelle: libelle ?? this.libelle,
      description: description ?? this.description,
      classe_id: classe_id ?? this.classe_id,
      matieres_id: matieres_id ?? this.matieres_id,
      categorie_id: categorie_id ?? this.categorie_id,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      open: open ?? this.open,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'video_url': video_url,
      'libelle': libelle,
      'description': description,
      'classe_id': classe_id,
      'matieres_id': matieres_id,
      'categorie_id': categorie_id,
      'created_at': created_at,
      'updated_at': updated_at,
      'open': open,
    };
  }

  factory Cours.fromMap(Map<String, dynamic> map) {
    return Cours(
      id: map['id'] as int,
      video_url: map['video_url'] as String,
      libelle: map['libelle'] as String,
      description: map['description'] as String,
      classe_id: map['classe_id'] as int,
      matieres_id: map['matieres_id'] as int,
      categorie_id: map['categorie_id'],
      created_at: map['created_at'] as String,
      updated_at: map['updated_at'] as String,
      open: map['open'].toString() == '0' || map['open'].toString() == 'false'
          ? false
          : true,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cours.fromJson(String source) =>
      Cours.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Cours(id: $id, video_url: $video_url, libelle: $libelle, description: $description, classe_id: $classe_id, matieres_id: $matieres_id, categorie_id: $categorie_id, created_at: $created_at, updated_at: $updated_at, open: $open)';
  }

  @override
  bool operator ==(covariant Cours other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.video_url == video_url &&
        other.libelle == libelle &&
        other.description == description &&
        other.classe_id == classe_id &&
        other.matieres_id == matieres_id &&
        other.categorie_id == categorie_id &&
        other.created_at == created_at &&
        other.updated_at == updated_at &&
        other.open == open;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        video_url.hashCode ^
        libelle.hashCode ^
        description.hashCode ^
        classe_id.hashCode ^
        matieres_id.hashCode ^
        categorie_id.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode ^
        open.hashCode;
  }
}
