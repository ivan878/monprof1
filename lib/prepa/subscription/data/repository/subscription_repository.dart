import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/subscription/data/models/payment_service_model.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_code_model.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:monprof/prepa/subscription/data/models/transaction_model.dart';
import 'package:monprof/prepa/subscription/data/services/subscription_service.dart';

class SubscriptionRepository {
  final SubscriptionService service;
  const SubscriptionRepository({required this.service});

  // ── Payment Services ─────────────────────────────────────────────────────────

  Future<AppState<List<PaymentServiceModel>>> listPaymentServices() async {
    try {
      final list = await service.listPaymentServices();
      final models = list
          .map((e) => PaymentServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return AppState(status: AppStatus.data, data: models);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PaymentServiceModel>> getPaymentServiceById(String id) async {
    try {
      final data = await service.getPaymentServiceById(id);
      return AppState(
        status: AppStatus.data,
        data: PaymentServiceModel.fromJson(data),
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<List<PaymentServiceModel>>> listPaymentServicesBySens(
    String sens,
  ) async {
    try {
      final list = await service.listPaymentServicesBySens(sens);
      final models = list
          .map((e) => PaymentServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return AppState(status: AppStatus.data, data: models);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── Subscriptions ────────────────────────────────────────────────────────────

  Future<AppState<SubscriptionModel>> createSubscription({
    required String concoursSessionId,
    required String paymentServiceId,
    required String phoneNumber,
    int count = 1,
  }) async {
    try {
      final data = await service.createSubscription(
        concoursSessionId: concoursSessionId,
        paymentServiceId: paymentServiceId,
        phoneNumber: phoneNumber,
        count: count,
      );
      return AppState(
        status: AppStatus.data,
        data: SubscriptionModel.fromJson(data),
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  /// POST /subscriptions → retourne la Transaction créée (pas la Subscription).
  /// Le backend répond avec un TransactionResponse après initiation du paiement.
  Future<AppState<TransactionModel>> initiatePayment({
    required String concoursSessionId,
    required String paymentServiceId,
    required String phoneNumber,
    int count = 1,
  }) async {
    try {
      final data = await service.createSubscription(
        concoursSessionId: concoursSessionId,
        paymentServiceId: paymentServiceId,
        phoneNumber: phoneNumber,
        count: count,
      );
      return AppState(
        status: AppStatus.data,
        data: TransactionModel.fromJson(data),
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<SubscriptionModel>> getSubscriptionById(String id) async {
    try {
      final data = await service.getSubscriptionById(id);
      return AppState(
        status: AppStatus.data,
        data: SubscriptionModel.fromJson(data),
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaPage<SubscriptionModel>>> listMySubscriptions({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final data = await service.listMySubscriptions(page: page, size: size);
      final page0 = PrepaPage.fromJson(data, SubscriptionModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaPage<SubscriptionModel>>> listMySubscriptionsByStatus(
    String status, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final data = await service.listMySubscriptionsByStatus(
        status,
        page: page,
        size: size,
      );
      final page0 = PrepaPage.fromJson(data, SubscriptionModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<SubscriptionModel?>> getMySubscriptionBySession(
      String sessionId) async {
    try {
      final data = await service.getMySubscriptionBySession(sessionId);
      return AppState(
        status: AppStatus.data,
        data: data != null ? SubscriptionModel.fromJson(data) : null,
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<void>> deleteSubscription(String id) async {
    try {
      await service.deleteSubscription(id);
      return AppState(status: AppStatus.data);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── Codes de souscription ────────────────────────────────────────────────────

  Future<AppState<List<SubscriptionCodeGroupModel>>> listMyCodeGroups() async {
    try {
      final list = await service.listMyCodeGroups();
      final models = list
          .map((e) =>
              SubscriptionCodeGroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return AppState(status: AppStatus.data, data: models);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  /// Consomme un code d'activation ; retourne la souscription créée.
  /// [concoursSessionId] restreint l'activation à la session attendue.
  Future<AppState<SubscriptionModel>> activateCode(
    String code, {
    String? concoursSessionId,
  }) async {
    try {
      final data = await service.activateCode(
        code,
        concoursSessionId: concoursSessionId,
      );
      return AppState(
        status: AppStatus.data,
        data: SubscriptionModel.fromJson(data),
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  // ── Transactions ─────────────────────────────────────────────────────────────

  Future<AppState<TransactionModel>> getTransactionById(String id) async {
    try {
      final data = await service.getTransactionById(id);
      return AppState(
        status: AppStatus.data,
        data: TransactionModel.fromJson(data),
      );
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaPage<TransactionModel>>> listMyTransactions({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final data = await service.listMyTransactions(page: page, size: size);
      final page0 = PrepaPage.fromJson(data, TransactionModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }
}
