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

  /// GET /cours/{id}/video-key
  ///
  /// Clé de déchiffrement d'une vidéo chiffrée. Le serveur ne la délivre qu'aux
  /// comptes disposant d'un accès actif au cours.
  Future<Map<String, dynamic>> getVideoKey(String coursId) async {
    final res = await dio.get('/cours/$coursId/video-key');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /concours-sessions/{sessionId}/matieres/{matiereId}/cours
  ///
  /// Cours de la matière effectivement rattachés à la session — et non tout le
  /// catalogue de la matière. Réponse non paginée (liste complète).
  Future<List<dynamic>> getSessionCoursByMatiere(
    String sessionId,
    String matiereId,
  ) async {
    final res =
        await dio.get('/concours-sessions/$sessionId/matieres/$matiereId/cours');
    final data = res.data['data'];
    return data is List ? data : const [];
  }
}
