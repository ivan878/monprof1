import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_model.dart';
import 'package:monprof/prepa/subscription/data/models/transaction_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

/// Gère le cycle complet d'un paiement :
///   1. Initiation (POST /subscriptions)
///   2. Polling (GET /transactions/{id}) toutes les 10 s jusqu'à SUCCESS / FAILED
class InitPaymentController extends ChangeNotifier {
  final SubscriptionRepository repository;

  InitPaymentController({required this.repository});

  // ── Phase 1 : initiation ──────────────────────────────────────────────────
  AppState<TransactionModel> initiationState = AppState();

  // ── Phase 2 : polling ─────────────────────────────────────────────────────
  AppState<TransactionModel> pollingState = AppState();
  Timer? _pollTimer;
  int _pollCount = 0;

  // 36 tentatives × 10 s = 6 minutes maximum
  static const _maxPolls = 36;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> initiate({
    required String sessionId,
    required String paymentServiceId,
    required String phoneNumber,
    int count = 1,
  }) async {
    initiationState = AppState(status: AppStatus.loading);
    notifyListeners();

    initiationState = await repository.initiatePayment(
      concoursSessionId: sessionId,
      paymentServiceId: paymentServiceId,
      phoneNumber: phoneNumber,
      count: count,
    );
    notifyListeners();

    if (initiationState.hasData) {
      final tx = initiationState.data!;
      _startPolling(tx.id);
    }
  }

  void _startPolling(String transactionId) {
    _pollCount = 0;
    pollingState = AppState(status: AppStatus.loading);
    notifyListeners();
    _pollTimer?.cancel();
    // Premiere vérification immédiate
    _poll(transactionId);
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _poll(transactionId);
    });
  }

  Future<void> _poll(String transactionId) async {
    _pollCount++;
    if (_pollCount > _maxPolls) {
      stopPolling();
      pollingState = AppState(
        status: AppStatus.error,
        errorModel: ErrorModel(
          error: 'Le délai de paiement a expiré. Veuillez réessayer.',
        ),
      );
      notifyListeners();
      return;
    }

    final result = await repository.getTransactionById(transactionId);
    if (!result.hasData) return;

    final tx = result.data!;
    pollingState = AppState(status: AppStatus.data, data: tx);
    notifyListeners();

    final s = tx.status?.toUpperCase() ?? '';
    if (s == 'SUCCESS' || s == 'FAILED' || s == 'CANCELED') {
      stopPolling();
    }
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void reset() {
    stopPolling();
    initiationState = AppState();
    pollingState = AppState();
    _pollCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
