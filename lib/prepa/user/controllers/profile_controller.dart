import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

class PrepaProfileController extends ChangeNotifier {
  final PrepaUserRepository repository;

  PrepaProfileController({required this.repository});

  AppState<PrepaUser> state = AppState();

  Future<void> loadProfile() async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();
    state = await repository.getMe();
    notifyListeners();
  }

  Future<void> refresh() => loadProfile();
}
