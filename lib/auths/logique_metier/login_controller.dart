import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/auths/datas/models/parents_model.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class LoginController extends GetxController {
  final UserRepository repository;

  LoginController({required this.repository});
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final formkey = GlobalKey<FormState>();
  AppState<Users?> state = AppState<Users?>();
  bool obscureText = true;

  chanObscureText() {
    obscureText = !obscureText;
    update();
  }

  Future login() async {
    if (formkey.currentState!.validate()) {
      state = AppState(status: AppStatus.loading);
      update();
      try {
        final data = await repository.login(
            controllerEmail.text, controllerPassword.text);
        final preference = await SharedPreferences.getInstance();

        final UserLocalStorageService storageService =
            UserLocalStorageService(preference: preference);
        final Users userResulte = data['user'];
        final String token = data['token'];
        await storageService.storeUser(userResulte);
        await storageService.storeToken(token);

        if (userResulte.isParent) {
          final ParentModel parenResult = data['parent'];
          await storageService.storeParent(parenResult);
        } else {
          final Eleve eleveResulte = data['eleve'];
          final Classe classeResulte = data['classe'];
          await storageService.storeClasse(classeResulte);
          await storageService.storeEleve(eleveResulte);
        }
        state = AppState(status: AppStatus.data, data: userResulte);
        update();
      } catch (e) {
        state = AppState(status: AppStatus.error, errorModel: returnError(e));
        update();
      }
    }
  }
}
