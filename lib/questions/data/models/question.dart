// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names

import 'package:monprof/questions/data/models/reponse.dart';

class Questions {
  int? id;
  String? titre;
  String? image_url;
  String description;
  int categorie_id;
  int matieres_id;
  Reponse? reponse;
  Questions({
    this.id,
    this.titre,
    this.reponse,
    this.image_url,
    required this.description,
    required this.categorie_id,
    required this.matieres_id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      if (titre != null) 'titre': titre,
      if (image_url != null) 'image_url': image_url,
      'description': description,
      'categorie_id': categorie_id,
      'matiere_id': matieres_id,
    };
  }

  factory Questions.fromMap(Map<String, dynamic> map) {
    return Questions(
      id: map['id'] != null ? map['id'] as int : null,
      titre: map['titre'] != null ? map['titre'] as String : null,
      image_url: map['image_url'] != null ? map['image_url'] as String : null,
      description: map['description'] as String,
      categorie_id: map['categorie_id'] as int,
      matieres_id: map['matieres_id'] as int,
      reponse: map['reponse'] != null ? Reponse.fromMap(map['reponse']) : null,
    );
  }

  @override
  String toString() {
    return 'Question(id: $id, titre: $titre, image_url:$image_url, description: $description, categorie_id: $categorie_id, matieres_id: $matieres_id)';
  }

  @override
  bool operator ==(covariant Questions other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.categorie_id == categorie_id &&
        other.matieres_id == matieres_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^ categorie_id.hashCode ^ matieres_id.hashCode;
  }
}
