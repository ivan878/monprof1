import 'package:dio/dio.dart';

class PrepaCoursService {
  final Dio dio;
  PrepaCoursService({required this.dio});

  /// GET /matieres?page=1&size=25
  Future<Map<String, dynamic>> listMatieres({int page = 1, int size = 25}) async {
    final res = await dio.get('/matieres', queryParameters: {
      'page': page,
      'size': size,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /matieres/{id}
  Future<Map<String, dynamic>> getMatiereById(String id) async {
    final res = await dio.get('/matieres/$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /cours?page=0&size=10
  Future<Map<String, dynamic>> listCours({int page = 0, int size = 10}) async {
    final res = await dio.get('/cours', queryParameters: {
      'page': page,
      'size': size,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /cours/{id}
  Future<Map<String, dynamic>> getCoursById(String id) async {
    final res = await dio.get('/cours/$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /cours/matiere/{matiereId}?page=0&size=10
  Future<Map<String, dynamic>> getCoursByMatiereId(
    String matiereId, {
    int page = 0,
    int size = 10,
  }) async {
    final res = await dio.get(
      '/cours/matiere/$matiereId',
      queryParameters: {'page': page, 'size': size},
    );
    return res.data['data'] as Map<String, dynamic>;
  }
}
