import 'package:get/get.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/data/models/matieres_models.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
import 'package:monprof/home/data/repository/home_repository.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class HomeController extends GetxController {
  HomeRepository repository;
  HomeController({required this.repository});

  AppState state = AppState();
  AppState<List<Matiere>?> matiereState =
      AppState<List<Matiere>?>(status: AppStatus.loading);
  AppState<List<CategorieStatus>?> categorieState =
      AppState<List<CategorieStatus>?>(status: AppStatus.loading);
  AppState<List<CategorieParentStatus>?> categorieParentState =
      AppState<List<CategorieParentStatus>?>(status: AppStatus.loading);

  CategorieStatus? categorie;
  CategorieParentStatus? categorieParent;
  Matiere? matiere;
  Users? users;
  Eleve? eleve;
  Classe? classe;

  @override
  onInit() async {
    super.onInit();
    await getData();
    initFunction();
  }

  Future initFunction() async {
    print(users!.ruleId);
    if (users!.isParent) {
      getCategoriePrentStatus();
    } else {
      getMatiere();
      getCategorie();
    }
    update();
  }

  static HomeController get data => Get.find();

  Future getData() async {
    final prefrence = await SharedPreferences.getInstance();
    final storage = UserLocalStorageService(preference: prefrence);
    users = storage.getUser();
    classe = storage.getClasse();
    eleve = storage.getEleve();
    update();
  }

  changeMatiere(Matiere? newMatiere) {
    matiere = newMatiere;
    update();
  }

  changeCategorie(CategorieStatus? newCategorie) {
    categorie = newCategorie;
    update();
  }

  changeCategorieParent(CategorieParentStatus? newCategorie) {
    categorieParent = newCategorie;
    update();
  }

  Future getMatiere() async {
    try {
      matiereState = AppState(status: AppStatus.loading);
      update();
      await repository.getMatieres().then((value) {
        matiereState =
            AppState<List<Matiere>?>(status: AppStatus.data, data: value);
        update();
      });
    } catch (e) {
      matiereState = AppState(
        status: AppStatus.error,
        data: null,
        errorModel: returnError(e),
      );
      update();
    }
  }

  //get categories
  Future getCategorie() async {
    try {
      categorieState = AppState(status: AppStatus.loading);
      update();
      await repository.getCategorieStatus().then((value) {
        categorieState = AppState<List<CategorieStatus>?>(
            status: AppStatus.data, data: value);
        update();
      }).onError((error, stackTrace) {
        categorieState = AppState(
          status: AppStatus.error,
          data: null,
          errorModel: returnError(error),
        );
        update();
      });
    } catch (e) {
      categorieState = AppState(
        status: AppStatus.error,
        data: null,
        errorModel: returnError(e),
      );
      update();
    }
  }

  //get categories Parent
  Future getCategoriePrentStatus() async {
    try {
      categorieParentState = AppState(status: AppStatus.loading);
      update();
      await repository.getCategoriePrentStatus().then((value) {
        final data = value;
        categorieParentState = AppState<List<CategorieParentStatus>?>(
            status: AppStatus.data, data: data);
        if (value.isNotEmpty) {
          categorieParent = value.first;
        }
        update();
      }).onError((error, stackTrace) {
        categorieParentState = AppState(
          status: AppStatus.error,
          data: null,
          errorModel: returnError(error),
        );
        update();
      });
    } catch (e) {
      categorieParentState = AppState(
        status: AppStatus.error,
        data: null,
        errorModel: returnError(e),
      );
      update();
    }
    update();
  }

  //
}
