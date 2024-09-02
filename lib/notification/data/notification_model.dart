// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotificationModel {
  String title;
  String body;
  String? imageUrl;
  int id;
  bool isRead;
  DateTime? createdAt;

  NotificationModel({
    required this.title,
    required this.body,
    this.imageUrl,
    required this.id,
    this.isRead = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'status': isRead,
      'id': id,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'],
      body: map['body'],
      imageUrl: map['imageUrl']?.toString(),
      isRead: map['status'],
      id: map['id'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  NotificationModel copyWith({
    String? title,
    String? body,
    String? imageUrl,
    int? id,
    bool? isRead,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      id: id ?? this.id,
      isRead: isRead ?? this.isRead,
    );
  }
}
