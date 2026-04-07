import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
import 'package:monprof/auths/datas/services/user_services.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/data/models/matieres_models.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
import 'package:monprof/home/data/repository/home_repository.dart';
import 'package:flutter_in_store_app_version_checker/flutter_in_store_app_version_checker.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:collection/collection.dart';
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

  AppState<Users> updateProfileState = AppState();

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
    updateToken();
  }

  Future initFunction() async {
    printer(users!.ruleId);
    if (users!.isParent) {
      getCategoriePrentStatus();
    } else {
      getMatiere();
      getCategorie();
    }
    update();
  }

  Future<void> listenserDeviceUpdated(BuildContext context) async {
    final bool isTest = users?.email == "engel@rich.com";
    if (isTest) return;
    final mobileDeviceIdentifier = await MobileDeviceIdentifier().getDeviceId();
    FirebaseFirestore.instance
        .collection('UserDevices')
        .doc(users!.phone)
        .snapshots()
        .listen((event) {
      if (event.data()?['user_device'] != mobileDeviceIdentifier) {
        // Notify.toastError("Vous vous êtes connecté sur un autre appareil");
        // logout();
        // Navigator.pushAndRemoveUntil(context,
        //     MaterialPageRoute(builder: (context) {
        //   return const LoginScreen();
        // }), (route) => false);
      }
    });

    // .set({
    //   'user_device': mobileDeviceIdentifier,
    // });
  }

  static HomeController get data => Get.find();

  Future updateToken() async {
    await GetIt.instance<UserService>().updateToken();
  }

  Future getData() async {
    final prefrence = await SharedPreferences.getInstance();
    final storage = UserLocalStorageService(preference: prefrence);
    users = storage.getUser();
    classe = storage.getClasse();
    eleve = storage.getEleve();
    update();
  }

  void changeMatiere(Matiere? newMatiere) {
    matiere = newMatiere;
    update();
  }

  void changeCategorie(CategorieStatus? newCategorie) {
    categorie = newCategorie;
    update();
  }

  void changeCategorieParent(CategorieParentStatus? newCategorie) {
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
        if (categorie != null) {
          changeCategorie(
            value.firstWhereOrNull(
              (element) => element.categorie.id == categorie?.categorie.id,
            ),
          );
        }
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

  Future<bool> logout() async {
    return await UserLocalStorageService.logout()
        .then((val) => true)
        .catchError((error, stackTrace) => false)
        .onError((error, stackTrace) => false);
  }

  Future updateProfileImage({File? imageProfile}) async {
    updateProfileState = AppState(status: AppStatus.loading);
    update();
    updateProfileState = await GetIt.instance<UserRepository>()
        .updateProfileImage(imageProfile!);
    Notify.toastSuccess('Profil mis à jour avec succès');
    update();
    if (updateProfileState.hasData) {
      users = updateProfileState.data;
      update();
    } else if (updateProfileState.hasError) {
      Notify.toastDanger(updateProfileState.errorModel!.error);
    }
  }

  Future<String> checkUpdate() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final checker = InStoreAppVersionChecker(
        androidStore: AndroidStore.googlePlayStore,
        appId: "mutrix_tech.monprof.app",
        currentVersion: packageInfo.version,
      );
      var status = await checker.checkUpdate();
      printer(
          "updated status  Version from package info ${packageInfo.version}");
      printer(
          "updated status canUpdate ${status.canUpdate}"); //return true if update is available
      printer(
          "updated status currentVersion ${status.currentVersion}"); //return current app version
      printer(
          "updated status newVersionn ${status.newVersion}"); //return the new app version
      printer("updated status appURL ${status.appURL}");
      printer("updated status errorMessage ${status.errorMessage}");

      if (status.canUpdate) {
        return "true";
      } else {
        return 'false';
      }
    } on SocketException {
      return "unable to reach internet! \nplease check your internet connexion";
    } catch (e) {
      debugPrint("errorCatchUpdate $e");
      return "error";
    }
  }

  Future<void> launchURL() async {
    final Uri appURL = Uri.parse(
        'https://play.google.com/store/apps/details?id=mutrix_tech.monprof.app');
    await launchUrl(appURL);
  }
}
