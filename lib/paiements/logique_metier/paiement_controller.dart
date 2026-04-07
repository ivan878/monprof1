import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/paiements/datas/models/paiement_provider.dart';
import 'package:monprof/paiements/datas/models/paiements.dart';
import 'package:monprof/home/logique_metier/home_controller.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';

class PaiementsController extends GetxController {
  PaiementRepository repository;

  PaiementsController({required this.repository, this.categorie});
  AppState<bool?> paiementState = AppState();
  TextEditingController controllerQuantite = TextEditingController();
  TextEditingController controllerNumeroClient = TextEditingController();
  TextEditingController controllerNumeroPayeur = TextEditingController();
  TextEditingController controllerCode = TextEditingController();

  AppState<List<PaiementProvider>> paiementProviderState = AppState();

  PaiementProvider? paiementProvider;
  bool successPayment = false;
  bool failedPayment = false;
  String? raisonFailedPayment;

  CategorieParentStatus? categorie;

  void changeCategorieParent(CategorieParentStatus? newCategorie) {
    categorie = newCategorie;
    update();
  }

  void changeSuccessPaymentStatue(bool val) {
    successPayment = val;
    update();
  }

  void changeFailedPaymentStatue(bool val) {
    failedPayment = val;
    update();
  }

  void chanRaisonFialedPayment(String? val) {
    raisonFailedPayment = val;
    update();
  }

  void changePaymentProvider(PaiementProvider? newPaiementProvider) {
    paiementProvider = newPaiementProvider;
    update();
  }

  void selectPaymentProviderFromNumber(String numero) {
    final data = paiementProviderState.data ?? [];
    // paiementProvider =
    //     paiementProviderState.data?.firstWhereOrNull((element) {});
    for (var element in data) {
      printer(element.regExp);
      printer(element.sens);
      printer(RegExp(element.regExp).hasMatch(numero));
      if (RegExp(element.regExp).hasMatch(numero) && element.sens == "IN") {
        paiementProvider = element;
        break;
      }
    }
    update();
    if (paiementProvider == null) {
      Notify.toastError("Numero du payeur invalide");
    }
  }

  int get totalPrice =>
      (int.tryParse(controllerQuantite.text) ?? 1) * categorie!.categorie.prix!;
  void changeQuantite(String val) {
    update();
  }

  Future requestPaiement() async {
    paiementState = AppState(status: AppStatus.loading);
    update();
    try {
      Paiements paiements = Paiements(
        numero_payeur: controllerNumeroPayeur.text,
        numero_client: controllerNumeroClient.text,
        nombre_de_code: int.tryParse(controllerQuantite.text) ?? 1,
        categorie_id: categorie?.categorie.id ??
            Get.find<HomeController>().categorie?.categorie.id,
        subscription_id: paiementProvider?.subscriptionId,
      );
      chanRaisonFialedPayment(null);
      changeSuccessPaymentStatue(false);
      changeFailedPaymentStatue(false);
      final response = await repository.requestPaiements(paiements);
      paiementState = AppState(data: response, status: AppStatus.data);
      update();
    } catch (e) {
      paiementState = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
      update();
    }
  }

  Future activeCode() async {
    paiementState = AppState(status: AppStatus.loading);
    update();
    try {
      final response = await repository.activeCode(controllerCode.text);
      paiementState = AppState(data: response, status: AppStatus.data);
      update();
    } catch (e) {
      paiementState = AppState(
        status: AppStatus.error,
        errorModel: returnError(e),
      );
      update();
    }
  }

  Future<void> getPaiementProviders() async {
    try {
      paiementProviderState = AppState(status: AppStatus.loading);
      update();
      final response = await repository.getPaymentServices();
      paiementProviderState = response;
      update();
    } catch (e) {
      paiementProviderState = AppState.track(e);
      update();
    } finally {
      update();
      if (paiementProviderState.hasError) {
        Notify.toastError(
          paiementProviderState.errorModel?.error ??
              'Une erreur est survenue lors du chargement des services de paiement',
        );
      }
    }
  }
}
