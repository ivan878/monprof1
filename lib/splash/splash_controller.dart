import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';

class SplaController extends GetxController {
  Locale locale = const Locale('fr');
  ThemeMode mode = ThemeMode.system;

  Future<Users?> checkUser() async {
    final preference = await SharedPreferences.getInstance();
    return UserLocalStorageService(preference: preference).getUser();
  }

  bool get isDarkmode => mode == ThemeMode.dark;

  Future checklocal() async {
    final preference = await SharedPreferences.getInstance();
    // await preference.setString(CURRENTLOCAL, 'en');
    final loc = preference.getString(CURRENTLOCAL) ?? 'fr';
    loger(loc);
    locale = Locale(loc.toString());
    // update();
  }

  Future updateLocal(Locale locale) async {
    Get.updateLocale(locale);
    final preference = await SharedPreferences.getInstance();
    await preference.setString(CURRENTLOCAL, locale.languageCode);
  }

  Future checkTheme() async {
    final preference = await SharedPreferences.getInstance();

    final isDark = preference.getBool(CURRENTTHEMEMODE);
    mode = isDark == null
        ? ThemeMode.system
        : isDark == true
            ? ThemeMode.dark
            : ThemeMode.light;
    Get.changeThemeMode(mode);
    // update();
  }

  Future updateThemMode(ThemeMode themeMode) async {
    Get.changeThemeMode(themeMode);
    mode = themeMode;
    update();
    // Notify.toast(mode.toString());
    final preference = await SharedPreferences.getInstance();
    await preference.setBool(
        CURRENTTHEMEMODE, themeMode == ThemeMode.dark ? true : false);
  }
}

// ignore: non_constant_identifier_names
String CURRENTLOCAL = "CURRENT_LOCAL";

// ignore: non_constant_identifier_names
String CURRENTTHEMEMODE = "CURRENT_THEME_MODE";
