import 'dart:convert';
import 'package:monprof/commons/constantes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';

class UserLocalStorageService {
  SharedPreferences preference;
  UserLocalStorageService({required this.preference});

  storeToken(String user) async {
    await preference.setString(userStorage, localToken);
  }

  String? getToken() {
    final tokenString = preference.getString(localToken);
    if ((tokenString ?? '').trim().isEmpty) {
      return null;
    }
    return tokenString;
  }

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

  storeClasse(Classe classe) async {
    final String classeString = jsonEncode(classe.toJson());
    await preference.setString(classeStorage, classeString);
  }

  Classe? getClasse() {
    final classetring = preference.getString(classeStorage);
    if ((classetring ?? '').trim().isEmpty) {
      return null;
    }
    final classe = Classe.fromJson(jsonDecode(classetring!));
    return classe;
  }

  storeEleve(Eleve eleve) async {
    final String eleveString = jsonEncode(eleve.toJson());
    await preference.setString(studentStorage, eleveString);
  }

  Eleve? getEleve() {
    final elevestring = preference.getString(studentStorage);
    if ((elevestring ?? '').trim().isEmpty) {
      return null;
    }
    final eleve = Eleve.fromJson(jsonDecode(studentStorage));
    return eleve;
  }
}
