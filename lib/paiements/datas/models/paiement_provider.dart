class PaiementProvider {
  final int id;
  final String title;
  final String? img;
  final String? description;
  final int status;
  final String subtitle;
  final int isActive;
  final String regExp;
  final int? subscriptionId;
  final String? sens;

  PaiementProvider({
    required this.id,
    required this.title,
    this.img,
    this.description,
    required this.status,
    required this.subtitle,
    required this.isActive,
    this.regExp = '',
    this.subscriptionId,
    this.sens,
  });

  factory PaiementProvider.fromMap(Map<String, dynamic> map) {
    return PaiementProvider(
      id: map['id'],
      title: map['title'],
      img: ((map['title'] as String).contains("MTN"))
          ? "assets/momo.jpg"
          : "assets/orange.png",
      description: map['description'],
      status: map['status'],
      subtitle: map['subtitle'],
      isActive: map['is_active'],
      regExp: map['reg_exp'],
      subscriptionId: map['subscription_id'],
      sens: map['sens'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'img': img,
      'description': description,
      'status': status,
      'subtitle': subtitle,
      'is_active': isActive,
      'reg_exp': regExp,
      'subscription_id': subscriptionId,
      'sens': sens,
    };
  }
}
