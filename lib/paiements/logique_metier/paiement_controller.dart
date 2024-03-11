import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
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

  CategorieParentStatus? categorie;

  changeCategorieParent(CategorieParentStatus? newCategorie) {
    categorie = newCategorie;
    update();
  }

  int get totalPrice =>
      (int.tryParse(controllerQuantite.text) ?? 1) * categorie!.categorie.prix!;
  changeQuantite(String val) {
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
      );
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
}
