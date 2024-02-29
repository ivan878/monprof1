

// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
class Reponse {
  String? titre;
String description;
String? image_url;
int questions_id;
  Reponse({
    this.titre,
    required this.description,
  this.image_url,
    required this.questions_id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titre': titre,
      'description': description,
      'image_url': image_url,
      'questions_id': questions_id,
    };
  }

  factory Reponse.fromMap(Map<String, dynamic> map) {
    return Reponse(
      titre: map['titre'] != null ? map['titre'] as String : null,
      description: map['description'] as String,
      image_url: map['image_url'] as String?,
      questions_id: map['questions_id'] as int,
    );
  }

}
