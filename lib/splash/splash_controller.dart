import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';

class SplaController extends GetxController {
  Future checkUser() async {
    final preference = await SharedPreferences.getInstance();
    return UserLocalStorageService(preference: preference).getUser();
  }
}
