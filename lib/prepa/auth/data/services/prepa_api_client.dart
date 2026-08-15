import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/helper.dart';

const String _prepaBaseUrl = 'https://api.prepa.mutrix.org/api/v1';
// const String prepaBasePath = '10.189.65.240';
const String prepaBasePath = 'https://api.prepa.mutrix.org';
// const String prepaBasePath = '192.168.1.40';
// const String _prepaBaseUrl = 'http://$prepaBasePath:8080/api/v1/';

/// Client Dio pour le backend prepa-concours.
/// Le Bearer token est l'ID Token Firebase de l'utilisateur courant.
/// Firebase SDK renouvelle l'ID token automatiquement (expire toutes les heures).
class PrepaApiClient {
  late final Dio _dio;

  PrepaApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _prepaBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.add(_PrepaInterceptor());
  }

  Dio get dio => _dio;
}

class _PrepaInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // forceRefresh: false → utilise le token en cache, le rafraîchit si expiré.
        final idToken = await firebaseUser.getIdToken(false);
        if (idToken != null && idToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (_) {}
    loger('[PrepaAPI] ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map && body['success'] == false) {
      final errMsg = body['error']?.toString() ?? 'Erreur inconnue';
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: CustomException(message: errMsg),
        type: DioExceptionType.badResponse,
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final body = err.response?.data;
    if (body is Map && body['error'] != null) {
      final msg = body['error'].toString();
      loger('[PrepaAPI] Erreur backend: $msg');
      handler.next(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: CustomException(message: msg),
      ));
      return;
    }
    loger('[PrepaAPI] Erreur: ${err.message}');
    super.onError(err, handler);
  }
}
