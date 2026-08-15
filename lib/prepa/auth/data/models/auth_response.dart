import 'package:monprof/prepa/auth/data/models/prepa_user.dart';

/// Miroir de UserResponse.java du backend.
class UserResponse {
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

  const UserResponse({
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

  factory UserResponse.fromJson(Map<String, dynamic> json) {
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

    return UserResponse(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
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

  PrepaUser toPrepaUser() => PrepaUser(
        id: id,
        fullName: fullName,
        email: email,
        phone: phone,
        firebaseUid: firebaseUid,
        profilePictureUrl: profilePictureUrl,
        roles: roles,
        hasPassword: hasPassword,
        hasEmailVerified: hasEmailVerified,
        hasPhoneVerified: hasPhoneVerified,
        hasProfileCompleted: hasProfileCompleted,
        isActive: isActive,
      );
}

/// Miroir de AuthResponse.java du backend.
/// token = Firebase Custom Token renvoyé après login/register OTP.
class AuthResponse {
  final UserResponse? userResponse;
  final String token;

  const AuthResponse({
    this.userResponse,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userResponse: json['userResponse'] is Map
          ? UserResponse.fromJson(
              json['userResponse'] as Map<String, dynamic>)
          : null,
      token: json['token']?.toString() ?? '',
    );
  }
}
