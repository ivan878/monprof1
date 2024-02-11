class User {
  int? ruleId;
  String? name;
  String? lastName;
  String? phone;
  String? email;
  String? uniqueToken;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  User({
    this.ruleId,
    this.name,
    this.lastName,
    this.phone,
    this.email,
    this.uniqueToken,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      ruleId: json['rule_id'],
      name: json['name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      uniqueToken: json['unique_token'],
      updatedAt: DateTime.parse(json['updated_at']),
      createdAt: DateTime.parse(json['created_at']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rule_id': ruleId,
      'name': name,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'unique_token': uniqueToken,
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'id': id,
    };
  }
}
