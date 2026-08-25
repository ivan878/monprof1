import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/paiements/datas/models/payment_creation_result.dart';
import 'package:monprof/paiements/datas/models/payment_request.dart';
import 'package:monprof/paiements/datas/models/payment_service.dart';
import 'package:monprof/paiements/datas/models/payment_transaction.dart';
import 'package:monprof/paiements/datas/services/paiements_services.dart';

class PaiementRepository {
  final PaiementServices services;
  PaiementRepository({required this.services});

  Future<PaymentCreationResult> createPayment(PaymentRequest payment) async {
    final data = await services.createPayment(payment);
    return PaymentCreationResult.fromMap(data);
  }

  Future<bool> activeCode(String code) async {
    try {
      final datas = await services.activeCode(code);
      return datas['status'];
    } catch (e) {
      rethrow;
    }
  }

  Future<AppState<List<PaymentService>>> getPaymentServices() async {
    try {
      final datas = await services.getPaymentServices();
      return AppState.complete(datas);
    } catch (e) {
      return AppState.track(e);
    }
  }

  Future<PaymentTransaction> getTransactionStatus(int transactionId) async {
    final response = await services.getTransactionStatus(transactionId);
    return PaymentTransaction.fromMap(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }
}
