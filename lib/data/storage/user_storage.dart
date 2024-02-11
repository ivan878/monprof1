import 'dart:convert';

import 'package:monprof/commons/constantes.dart';
import 'package:monprof/domains/modeles/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  SharedPreferences preference;
  UserLocalStorage({required this.preference});

  storeUser(User user) async {
    final String userString = jsonEncode(user.toJson());
    await preference.setString(userStorage, userString);
  }

  User? getUser() {
    final userstring = preference.getString(userStorage);
    if ((userstring ?? '').trim().isEmpty) {
      return null;
    }
    final user = User.fromJson(jsonDecode(userstring!));
    return user;
  }
}
