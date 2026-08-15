import 'dart:convert';

/// Modèle utilisateur local — miroir de UserResponse.java.
/// Utilisé dans toute l'app après conversion depuis UserResponse.
class PrepaUser {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? firebaseUid;
  final String? profilePictureUrl;
  final List<String> roles;
  final bool hasPassword;
  final bool hasEmailVerified;
  final bool hasPhoneVerified;
  final bool hasProfileCompleted;
  final bool? isActive;

  const PrepaUser({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.firebaseUid,
    this.profilePictureUrl,
    this.roles = const [],
    this.hasPassword = false,
    this.hasEmailVerified = false,
    this.hasPhoneVerified = false,
    this.hasProfileCompleted = false,
    this.isActive,
  });

  /// Alias de compatibilité pour le code existant.
  String get name => fullName;

  bool get isAdmin => roles.contains('ADMIN') || roles.contains('ROLE_ADMIN');

  factory PrepaUser.fromJson(Map<String, dynamic> json) {
    List<String> parseRoles(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .map((r) {
              if (r is Map) return r['name']?.toString() ?? '';
              return r.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    }

    return PrepaUser(
      id: json['id']?.toString() ?? '',
      // Supporte les deux clés pour la compatibilité ascendante du stockage local.
      fullName: (json['fullName'] ?? json['name'])?.toString() ?? '',
      email: json['email']?.toString(),
      phone: (json['phone'] ?? json['phoneNumber'])?.toString(),
      firebaseUid: json['firebaseUid']?.toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
      roles: parseRoles(json['roles']),
      hasPassword: json['hasPassword'] as bool? ?? false,
      hasEmailVerified: json['hasEmailVerified'] as bool? ?? false,
      hasPhoneVerified: json['hasPhoneVerified'] as bool? ?? false,
      hasProfileCompleted: json['hasProfileCompleted'] as bool? ?? false,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (firebaseUid != null) 'firebaseUid': firebaseUid,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        'roles': roles,
        'hasPassword': hasPassword,
        'hasEmailVerified': hasEmailVerified,
        'hasPhoneVerified': hasPhoneVerified,
        'hasProfileCompleted': hasProfileCompleted,
        if (isActive != null) 'isActive': isActive,
      };

  String toJsonString() => jsonEncode(toJson());

  factory PrepaUser.fromJsonString(String source) =>
      PrepaUser.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
