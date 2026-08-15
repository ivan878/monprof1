import 'package:dio/dio.dart';
import 'package:monprof/prepa/auth/data/models/auth_response.dart';

class PrepaUserService {
  final Dio dio;
  PrepaUserService({required this.dio});

  Future<UserResponse> getMe() async {
    final res = await dio.get('/users/me');
    return UserResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserResponse> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (profilePictureUrl != null) body['profilePictureUrl'] = profilePictureUrl;
    final res = await dio.put('/users/me', data: body);
    return UserResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserResponse> uploadProfilePicture(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await dio.post('/users/me/picture', data: formData);
    return UserResponse.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await dio.put('/users/fcm-token', data: {'fcmToken': fcmToken});
  }

  Future<void> updatePassword({
    required int oldPassword,
    required int newPassword,
  }) async {
    await dio.put('/users/password/update', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> setPassword(int newPassword) async {
    await dio.put('/users/me/set-password', data: {'newPassword': newPassword});
  }
}
