import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class ActivateCodeController extends ChangeNotifier {
  final SubscriptionRepository repository;

  ActivateCodeController({required this.repository});

  AppState<SubscriptionModel> state = AppState();

  Future<void> activate(String code, {String? concoursSessionId}) async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();

    // Le backend normalise déjà, mais on évite d'envoyer les tirets de saisie.
    final normalized = code.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    state = await repository.activateCode(
      normalized,
      concoursSessionId: concoursSessionId,
    );
    notifyListeners();
  }

  void reset() {
    state = AppState();
    notifyListeners();
  }
}
