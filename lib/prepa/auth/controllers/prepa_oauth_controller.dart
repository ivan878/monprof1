import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';

class PrepaOAuthController extends ChangeNotifier {
  final PrepaAuthRepository repository;

  PrepaOAuthController({required this.repository});

  AppState<PrepaUser> oAuthState = AppState();

  Future<void> signInWithGoogle() async {
    oAuthState = AppState(status: AppStatus.loading);
    notifyListeners();
    oAuthState = await repository.signInWithGoogle();
    notifyListeners();
  }

  Future<void> signInWithApple() async {
    oAuthState = AppState(status: AppStatus.loading);
    notifyListeners();
    oAuthState = await repository.signInWithApple();
    notifyListeners();
  }

  void reset() {
    oAuthState = AppState();
    notifyListeners();
  }
}
