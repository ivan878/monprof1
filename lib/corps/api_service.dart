import 'package:dio/dio.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:monprof/corps/uri.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
// import 'dart:developer';

class ApiInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    loger('Request: ${options.uri}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map && response.data['status'] == false) {
      throw CustomException(
        message: response.data['error'],
      );
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    loger(
        'Error ${err.message ?? err.response?.data ?? err.toString()}, URI: ${err.requestOptions.uri}, Code: ${err.response?.statusCode}');
    if (err.response?.statusCode == 401) {
      final newToken = await reFreshToken();
      if (newToken != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        return handler.resolve(await Dio().fetch(err.requestOptions));
      } else {
        return handler.next(err);
      }
    }
    return super.onError(err, handler);
  }
}

// InterceptorsWrapper wrapper = InterceptorsWrapper(
//   onResponse: (response, handler) {
//     printer(
//         "Data ${response.data},\n URI: ${response.realUri}, Code: ${response.statusCode}");
//     return handler.next(response);
//   },
//   onRequest: (request, handler) {
//     return handler.next(request);
//   },
//   onError: (error, handler) async {
//     printer(
//       "Error ${error.message ?? error.response?.data ?? error.toString()},\n URI: ${error.requestOptions.uri}, Code: ${error.response?.statusCode}",
//       type: 'e',
//     );

//     return handler.next(error);
//   },
// );

class PublicAPI {
  final Dio dios = Dio(BaseOptions(
    baseUrl: BASE_URL, // URL de base
    connectTimeout: const Duration(seconds: 90),
    receiveTimeout: const Duration(seconds: 90),
  ));
  Dio get dio => dios;
  PublicAPI() {
    dios.interceptors.addAll([ApiInterceptor()]);
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
    dios.interceptors.add(ApiInterceptor());
  }
}

Future<Map<String, dynamic>> header() async {
  final preference = await SharedPreferences.getInstance();
  final mobileDeviceIdentifier = await MobileDeviceIdentifier().getDeviceId();
  String? token = UserLocalStorageService(preference: preference).getToken();
  loger('Bearer $token');
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
    "phone-emei": mobileDeviceIdentifier,
  };
}

Future<String?> reFreshToken() async {
  try {
    final dio = Dio();
    final preference = await SharedPreferences.getInstance();
    final userstorage = UserLocalStorageService(preference: preference);
    final token = userstorage.getRefreshToken();
    final response = await dio.post(
      '${BASE_URL}auth/refresh-token',
      data: {'refresh_token': token},
      options: Options(
        headers: await header(),
      ),
    );
    if (response.data?['status'] == true) {
      final newToken = response.data?['data']['token'];
      userstorage.storeToken(newToken ?? '');
      userstorage.storeRefreshToken(response.data?['data']['refresh_token']);
      return newToken;
    } else {
      return null;
    }
  } catch (e) {
    loger(e);
    return null;
  }
}
