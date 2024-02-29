import 'dart:developer';

class Users {
  Users({
    required this.name,
    this.lastName,
    required this.email,
    required this.phone,
    this.ruleId,
    this.id,
    this.uniqueToken,
    this.updatedAt,
    this.createdAt,
  });
  // Méthode pour créer une instance Users à partir d'un Map JSON
  factory Users.fromJson(Map<String, dynamic> json) {
    log(json['name'].toString());
    return Users(
      name: json['name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      ruleId: json['rule_id'] ?? 0,
      id: json['id'],
      uniqueToken: json['unique_token'],
      updatedAt: DateTime.parse(json['updated_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Méthode pour convertir l'instance Users en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'ruleId': ruleId,
      if (id != null) 'id': id,
      'unique_token': uniqueToken,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Méthode pour comparer deux instances Users
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Users &&
        other.name == name &&
        other.lastName == lastName &&
        other.email == email &&
        other.phone == phone &&
        other.ruleId == ruleId &&
        other.id == id;
  }

  String name;
  String? lastName;
  String email;
  String phone;
  int? ruleId;
  int? id;
  String? uniqueToken;
  DateTime? updatedAt;
  DateTime? createdAt;

  // Méthode pour obtenir le hash code de l'instance Users
  @override
  int get hashCode {
    return name.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        ruleId.hashCode ^
        id.hashCode;
  }
}
