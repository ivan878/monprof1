class Student {
  String? sexe;
  String? etablissement;
  int? classeId;
  int? userId;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Student({
    this.sexe,
    this.etablissement,
    this.classeId,
    this.userId,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      sexe: json['sexe'],
      etablissement: json['etablissement'],
      classeId: json['classe_id'],
      userId: json['user_id'],
      updatedAt: DateTime.parse(json['updated_at']),
      createdAt: DateTime.parse(json['created_at']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sexe': sexe,
      'etablissement': etablissement,
      'classe_id': classeId,
      'user_id': userId,
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'id': id,
    };
  }
}
