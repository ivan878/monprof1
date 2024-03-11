import 'package:dio/dio.dart';
import 'package:monprof/corps/uri.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
// import 'dart:developer';

InterceptorsWrapper wrapper = InterceptorsWrapper(
  onResponse: (response, handler) {
    printer(
        "Data ${response.data},\n URI: ${response.realUri}, Code: ${response.statusCode}");
    return handler.next(response);
  },
  onRequest: (request, handler) {
    return handler.next(request);
  },
  onError: (error, handler) async {
    printer(
      "Error ${error.message ?? error.response?.data ?? error.toString()},\n URI: ${error.requestOptions.uri}, Code: ${error.response?.statusCode}",
      type: 'e',
    );
    if (error.response?.statusCode == 401) {
      final newToken = await reFreshToken();
      error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      return handler.resolve(await Dio().fetch(error.requestOptions));
    }
    return handler.next(error);
  },
);

class PublicAPI {
  final Dio dios = Dio(BaseOptions(
    baseUrl: BASE_URL, // URL de base
    // connectTimeout: 5000, // Délai d'attente pour établir une connexion (en millisecondes)
    // receiveTimeout: 3000, // Délai d'attente pour recevoir des données (en millisecondes)
  ));
  Dio get dio => dios;
  PublicAPI() {
    dios.interceptors.add(wrapper);
  }
}

class API {
  final Dio dios = Dio(
    BaseOptions(
      baseUrl: BASE_URL, // URL de base
    ),
  );
  Dio get dio => dios;
  API() {
    dios.interceptors.add(wrapper);
  }
}

Future<Map<String, dynamic>> header() async {
  final preference = await SharedPreferences.getInstance();
  String? token = UserLocalStorageService(preference: preference).getToken();
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

Future<String?> reFreshToken() async {
  try {
    final dio = Dio();
    final preference = await SharedPreferences.getInstance();
    final userstorage = UserLocalStorageService(preference: preference);
    final token = userstorage.getToken();
    loger(token ?? 'le token est vide');
    final response = await dio.post(
      '${BASE_URL}auth/refresh-token',
      data: {'token': token},
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    loger(response.data.toString());
    if (response.data?['status'] == true) {
      final newToken = response.data?['data']['token'];
      userstorage.storeToken(newToken ?? '');
      return newToken;
    } else {
      return null;
    }
  } catch (e) {
    loger(e);
    return null;
  }
}
