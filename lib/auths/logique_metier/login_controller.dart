import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/commons/app_state.dart';
import 'package:monprof/commons/error_handler.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class LoginController extends GetxController {
  final UserRepository repository;

  LoginController({required this.repository});
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final formkey = GlobalKey<FormState>();
  AppState state = AppState();
  bool obscureText = true;

  chanObscureText(bool obscure) {
    obscureText = obscure;
    update();
  }

  Future login() async {
    if (formkey.currentState!.validate()) {
      state = AppState(status: AppStatus.loading);
      update();
      try {
        final data = await repository.login(
            controllerEmail.text, controllerPassword.text);
        state = AppState(status: AppStatus.data, data: data);
        update();
      } catch (e) {
        state = AppState(status: AppStatus.error, errorModel: returnError(e));
        update();
      }
    }
  }
}
