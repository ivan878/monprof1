import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class RegisterController extends GetxController {
  final UserRepository repository;

  RegisterController({required this.repository});
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEtablissement = TextEditingController();
  TextEditingController controllerLastName = TextEditingController();
  String controllerSexe = 'HOMME';
  TextEditingController controllerPhone = TextEditingController();
  final sexesChoices = <String>[
    'FEMME',
    'HOMME',
  ];

  List<Classe>? classes;
  Classe? classe;

  final formkey = GlobalKey<FormState>();
  AppState state = AppState();
  AppState<List<Classe>?> classeState =
      AppState<List<Classe>?>(status: AppStatus.loading);

  bool obscureText = true;
  bool politiqueAccepted = false;

  @override
  onInit() {
    getClasse();
    update();
    super.onInit();
  }

  chanObscureText(bool obscure) {
    obscureText = obscure;
    update();
  }

  changePolitique(bool value) {
    politiqueAccepted = value;
    update();
  }

  changeClasse(Classe? classeChoices) {
    classe = classeChoices;
    update();
  }

  changeSexe(String? sexe) {
    controllerSexe = sexe ?? '';
    update();
  }

  Future register() async {
    if (formkey.currentState!.validate()) {
      state = AppState(status: AppStatus.loading);
      update();
      try {
        Users users = Users(
          name: controllerName.text,
          email: controllerEmail.text,
          phone: controllerPhone.text,
          lastName: controllerLastName.text,
        );
        Eleve eleve = Eleve(
          etablissement: controllerEtablissement.text,
          sexe: controllerSexe,
          classeId: classe!.id!,
        );
        final data =
            await repository.register(users, eleve, controllerPassword.text);
        final preference = await SharedPreferences.getInstance();

        final Users userResulte = data['user'];
        final Eleve eleveResulte = data['eleve'];
        final Classe classeResulte = data['classe'];
        final String token = data['token'];
        final UserLocalStorageService storageService =
            UserLocalStorageService(preference: preference);
        await storageService.storeClasse(classeResulte);
        await storageService.storeUser(userResulte);
        await storageService.storeEleve(eleveResulte);
        await storageService.storeToken(token);
        state = AppState(status: AppStatus.data, data: data);
        update();
      } catch (e) {
        state = AppState(status: AppStatus.error, errorModel: returnError(e));
        update();
      }
    }
  }

  Future getClasse() async {
    try {
      await repository.getClasse().then((value) {
        classeState =
            AppState<List<Classe>?>(status: AppStatus.data, data: value);
        update();
      });
    } catch (e) {
      classeState = AppState(
        status: AppStatus.error,
        data: null,
        errorModel: returnError(e),
      );
      update();
    }
  }
}
