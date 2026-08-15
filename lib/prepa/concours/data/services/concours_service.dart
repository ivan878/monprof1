import 'package:dio/dio.dart';

class ConcoursService {
  final Dio dio;
  ConcoursService({required this.dio});

  /// GET /concours?page=1&size=20 → data: PrepaPage of ConcoursModel
  Future<Map<String, dynamic>> listConcours({int page = 1, int size = 20}) async {
    final res = await dio.get('/concours', queryParameters: {
      'page': page,
      'size': size,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /concours/{id}
  Future<Map<String, dynamic>> getConcoursById(String id) async {
    final res = await dio.get('/concours/$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /concours-sessions?page=1&size=25
  Future<Map<String, dynamic>> listSessions({int page = 1, int size = 25}) async {
    final res = await dio.get('/concours-sessions', queryParameters: {
      'page': page,
      'size': size,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /concours-sessions/{id}
  Future<Map<String, dynamic>> getSessionById(String id) async {
    final res = await dio.get('/concours-sessions/$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /concours-sessions/concours/{concoursId}?page=1&size=25
  Future<Map<String, dynamic>> getSessionsByConcoursId(
    String concoursId, {
    int page = 1,
    int size = 25,
  }) async {
    final res = await dio.get(
      '/concours-sessions/concours/$concoursId',
      queryParameters: {'page': page, 'size': size},
    );
    return res.data['data'] as Map<String, dynamic>;
  }
}
