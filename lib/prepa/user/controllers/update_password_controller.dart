import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

class UpdatePasswordController extends ChangeNotifier {
  final PrepaUserRepository repository;

  UpdatePasswordController({required this.repository});

  AppState<void> state = AppState();

  Future<void> updatePassword({
    required int oldPassword,
    required int newPassword,
  }) async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();

    state = await repository.updatePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    notifyListeners();
  }

  void reset() {
    state = AppState();
    notifyListeners();
  }
}
