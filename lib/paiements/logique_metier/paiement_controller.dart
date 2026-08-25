import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/datas/models/payment_creation_result.dart';
import 'package:monprof/paiements/datas/models/payment_request.dart';
import 'package:monprof/paiements/datas/models/payment_service.dart';
import 'package:monprof/paiements/datas/models/payment_transaction.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';

class PaiementsController extends GetxController {
  static const Duration pollingInterval = Duration(seconds: 7);

  final PaiementRepository repository;

  PaiementsController({required this.repository, this.categorie});

  final TextEditingController controllerQuantite = TextEditingController();
  final TextEditingController controllerNumeroClient = TextEditingController();
  final TextEditingController controllerNumeroPayeur = TextEditingController();
  final TextEditingController controllerCode = TextEditingController();

  AppState<PaymentCreationResult?> paymentCreationState = AppState();
  AppState<bool?> codeActivationState = AppState();
  AppState<List<PaymentService>> paymentServiceState = AppState();

  CategorieParentStatus? categorie;
  PaymentService? selectedPaymentService;
  PaymentTransaction? currentTransaction;
  PaymentFlowStatus paymentFlowStatus = PaymentFlowStatus.idle;
  String? paymentFailureReason;
  String? pollingError;
  Timer? _pollingTimer;
  bool _statusRequestInProgress = false;

  void changeCategorieParent(CategorieParentStatus? newCategorie) {
    categorie = newCategorie;
    update();
  }

  Categorie? get selectedCategory =>
      categorie?.categorie ?? Get.find<HomeController>().categorie?.categorie;

  int get totalPrice {
    final unitPrice = selectedCategory?.prix ?? 0;
    return (int.tryParse(controllerQuantite.text) ?? 1) * unitPrice;
  }

  int get serviceFee => selectedPaymentService?.serviceFeeFor(totalPrice) ?? 0;

  int get totalAmount => totalPrice + serviceFee;

  void changeQuantity(String _) => update();

  void selectPaymentServiceFromNumber(String phoneNumber) {
    final normalizedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    selectedPaymentService = null;

    for (final service in paymentServiceState.data ?? <PaymentService>[]) {
      if (service.acceptsPhoneNumber(normalizedNumber)) {
        selectedPaymentService = service;
        break;
      }
    }

    update();
  }

  bool validateSelectedPaymentService({bool showError = true}) {
    selectPaymentServiceFromNumber(controllerNumeroPayeur.text);
    final valid = selectedPaymentService != null;

    if (!valid && showError) {
      Notify.toastError(
        'Aucun service de paiement ne correspond à ce numéro'.tr,
      );
    }

    return valid;
  }

  Future<bool> requestPayment() async {
    if (!validateSelectedPaymentService()) {
      return false;
    }

    final categoryId = selectedCategory?.id;
    if (categoryId == null) {
      Notify.toastError('La catégorie sélectionnée est invalide'.tr);
      return false;
    }

    stopPolling();
    paymentFlowStatus = PaymentFlowStatus.creating;
    paymentFailureReason = null;
    pollingError = null;
    currentTransaction = null;
    paymentCreationState = AppState.loading();
    update();

    try {
      final result = await repository.createPayment(
        PaymentRequest(
          payerPhoneNumber: controllerNumeroPayeur.text,
          beneficiaryPhoneNumber: controllerNumeroClient.text,
          quantity: int.tryParse(controllerQuantite.text) ?? 1,
          categoryId: categoryId,
          paymentServiceId: selectedPaymentService!.id,
        ),
      );

      paymentCreationState = AppState.complete(result);
      currentTransaction = result.transaction;
      _applyTransactionStatus(result.transaction);

      if (!result.transaction.isFinal) {
        paymentFlowStatus = PaymentFlowStatus.pending;
        startPolling();
      }

      update();
      return true;
    } catch (error) {
      paymentCreationState = AppState.track(error);
      paymentFlowStatus = PaymentFlowStatus.failed;
      paymentFailureReason = returnError(error).error;
      update();
      return false;
    }
  }

  void startPolling() {
    if (currentTransaction == null || currentTransaction!.isFinal) {
      return;
    }

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(pollingInterval, (_) {
      checkTransactionStatus();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> checkTransactionStatus() async {
    final transaction = currentTransaction;
    if (transaction == null ||
        transaction.isFinal ||
        _statusRequestInProgress) {
      return;
    }

    _statusRequestInProgress = true;
    try {
      final updatedTransaction =
          await repository.getTransactionStatus(transaction.id);
      pollingError = null;
      currentTransaction = updatedTransaction;
      _applyTransactionStatus(updatedTransaction);
    } catch (error) {
      // Une coupure réseau ne doit pas transformer un paiement en échec.
      pollingError = returnError(error).error;
    } finally {
      _statusRequestInProgress = false;
      update();
    }
  }

  void _applyTransactionStatus(PaymentTransaction transaction) {
    if (!transaction.isFinal) {
      paymentFlowStatus = PaymentFlowStatus.pending;
      return;
    }

    stopPolling();
    if (transaction.isSuccessful) {
      paymentFlowStatus = PaymentFlowStatus.success;
      paymentFailureReason = null;
    } else {
      paymentFlowStatus = PaymentFlowStatus.failed;
      paymentFailureReason =
          transaction.failureReason?.trim().isNotEmpty == true
              ? transaction.failureReason
              : 'Le paiement a été refusé'.tr;
    }
  }

  Future<void> getPaymentServices() async {
    paymentServiceState = AppState.loading();
    update();

    paymentServiceState = await repository.getPaymentServices();
    update();

    if (paymentServiceState.hasError) {
      Notify.toastError(
        paymentServiceState.errorModel?.error ??
            'Impossible de charger les services de paiement'.tr,
      );
    }
  }

  Future<void> activeCode() async {
    codeActivationState = AppState.loading();
    update();

    try {
      final response = await repository.activeCode(controllerCode.text);
      codeActivationState = AppState.complete(response);
    } catch (error) {
      codeActivationState = AppState.track(error);
    } finally {
      update();
    }
  }

  void resetPaymentFlow() {
    stopPolling();
    paymentCreationState = AppState();
    currentTransaction = null;
    paymentFlowStatus = PaymentFlowStatus.idle;
    paymentFailureReason = null;
    pollingError = null;
    update();
  }

  @override
  void onClose() {
    stopPolling();
    controllerQuantite.dispose();
    controllerNumeroClient.dispose();
    controllerNumeroPayeur.dispose();
    controllerCode.dispose();
    super.onClose();
  }
}
