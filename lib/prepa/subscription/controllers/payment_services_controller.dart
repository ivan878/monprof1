import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/subscription/data/models/payment_service_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class PaymentServicesController extends ChangeNotifier {
  final SubscriptionRepository repository;

  PaymentServicesController({required this.repository});

  AppState<List<PaymentServiceModel>> state = AppState();

  Future<void> loadPaymentServices() async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();
    state = await repository.listPaymentServices();
    notifyListeners();
  }

  Future<void> loadDebitServices() async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();
    state = await repository.listPaymentServicesBySens('IN');
    notifyListeners();
  }

  Future<void> refresh() => loadPaymentServices();
}
