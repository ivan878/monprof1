import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/user/data/services/user_service.dart';

class PrepaUserRepository {
  final PrepaUserService service;
  const PrepaUserRepository({required this.service});

  Future<AppState<PrepaUser>> getMe() async {
    try {
      final userResponse = await service.getMe();
      return AppState(status: AppStatus.data, data: userResponse.toPrepaUser());
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaUser>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    try {
      final userResponse = await service.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
      );
      return AppState(status: AppStatus.data, data: userResponse.toPrepaUser());
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaUser>> uploadProfilePicture(String filePath) async {
    try {
      final userResponse = await service.uploadProfilePicture(filePath);
      return AppState(status: AppStatus.data, data: userResponse.toPrepaUser());
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<void>> setPassword(int newPassword) async {
    try {
      await service.setPassword(newPassword);
      return AppState(status: AppStatus.data);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<void>> updateFcmToken(String fcmToken) async {
    try {
      await service.updateFcmToken(fcmToken);
      return AppState(status: AppStatus.data);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<void>> updatePassword({
    required int oldPassword,
    required int newPassword,
  }) async {
    try {
      await service.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return AppState(status: AppStatus.data);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }
}
