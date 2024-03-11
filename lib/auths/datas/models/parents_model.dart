// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ParentModel {
  String profession;
  String sexe;
  int? userId;
  int? id;
  DateTime? updatedAt;
  DateTime? createdAt;
  ParentModel({
    required this.profession,
    required this.sexe,
    this.userId,
    this.id,
    this.updatedAt,
    this.createdAt,
  });

  ParentModel copyWith({
    String? profession,
    String? sexe,
    int? userId,
    int? id,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return ParentModel(
      profession: profession ?? this.profession,
      sexe: sexe ?? this.sexe,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'profession': profession,
      'sexe': sexe,
      if (userId != null) 'userId': userId,
      if (id != null) 'id': id,
      if (userId != null) 'updatedAt': updatedAt?.millisecondsSinceEpoch,
      if (createdAt != null) 'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      profession: map['profession'] as String,
      sexe: map['sexe'] as String,
      userId: map['userId'] != null ? map['userId'] as int : null,
      id: map['id'] != null ? map['id'] as int : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ParentModel.fromJson(String source) =>
      ParentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ParentModel(profession: $profession, sexe: $sexe, userId: $userId, id: $id, updatedAt: $updatedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant ParentModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId && other.id == id;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ id.hashCode;
  }
}
