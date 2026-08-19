import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/common/apple_review_mode.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

class PrepaProfileController extends ChangeNotifier {
  final PrepaUserRepository repository;

  PrepaProfileController({required this.repository});

  AppState<PrepaUser> state = AppState();

  Future<void> loadProfile() async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();
    state = await repository.getMe();
    // Profil frais venu du serveur : c'est la source la plus fiable pour
    // réévaluer le mode restreint iOS.
    if (state.hasData) AppleReviewMode.instance.applyTo(state.data);
    notifyListeners();
  }

  Future<void> refresh() => loadProfile();
}
