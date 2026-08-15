import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class CreateSubscriptionController extends ChangeNotifier {
  final SubscriptionRepository repository;

  CreateSubscriptionController({required this.repository});

  AppState<SubscriptionModel> state = AppState();

  Future<void> createSubscription({
    required String concoursSessionId,
    required String paymentServiceId,
    required String phoneNumber,
    int count = 1,
  }) async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();

    state = await repository.createSubscription(
      concoursSessionId: concoursSessionId,
      paymentServiceId: paymentServiceId,
      phoneNumber: phoneNumber,
      count: count,
    );
    notifyListeners();
  }

  void reset() {
    state = AppState();
    notifyListeners();
  }
}
