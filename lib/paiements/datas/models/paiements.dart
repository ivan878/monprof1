import 'dart:convert';
// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names

class Paiements {
  String numero_payeur;
  String numero_client;
  int nombre_de_code;
  int? categorie_id;
  Paiements({
    required this.numero_payeur,
    required this.numero_client,
    required this.nombre_de_code,
    this.categorie_id,
  });

  Paiements copyWith({
    String? numero_payeur,
    String? numero_client,
    int? nombre_de_code,
    int? categorie_id,
  }) {
    return Paiements(
      numero_payeur: numero_payeur ?? this.numero_payeur,
      numero_client: numero_client ?? this.numero_client,
      nombre_de_code: nombre_de_code ?? this.nombre_de_code,
      categorie_id: categorie_id ?? this.categorie_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'numero_payeur': numero_payeur,
      'numero_client': numero_client,
      'nombre_de_code': nombre_de_code,
      'categorie_id': categorie_id,
    };
  }

  factory Paiements.fromMap(Map<String, dynamic> map) {
    return Paiements(
      numero_payeur: map['numero_payeur'] as String,
      numero_client: map['numero_client'] as String,
      nombre_de_code: map['nombre_de_code'] as int,
      categorie_id: map['categorie_id'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Paiements.fromJson(String source) =>
      Paiements.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Paiements(numero_payeur: $numero_payeur, numero_client: $numero_client, nombre_de_code: $nombre_de_code, categorie_id: $categorie_id)';
  }

  @override
  bool operator ==(covariant Paiements other) {
    if (identical(this, other)) return true;

    return other.numero_payeur == numero_payeur &&
        other.numero_client == numero_client &&
        other.nombre_de_code == nombre_de_code &&
        other.categorie_id == categorie_id;
  }

  @override
  int get hashCode {
    return numero_payeur.hashCode ^
        numero_client.hashCode ^
        nombre_de_code.hashCode ^
        categorie_id.hashCode;
  }
}
