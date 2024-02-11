import 'dart:convert';

import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/commons/constantes.dart';

import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  SharedPreferences preference;
  UserLocalStorage({required this.preference});

  storeUser(Users user) async {
    final String userString = jsonEncode(user.toJson());
    await preference.setString(userStorage, userString);
  }

  Users? getUser() {
    final userstring = preference.getString(userStorage);
    if ((userstring ?? '').trim().isEmpty) {
      return null;
    }
    final user = Users.fromJson(jsonDecode(userstring!));
    return user;
  }
}
