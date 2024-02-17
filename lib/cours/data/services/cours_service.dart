import 'package:dio/dio.dart';
import 'package:monprof/corps/api_service.dart';

class CoursService {
  final Dio dio;

  CoursService({required this.dio});

  Future<Map<String, dynamic>> getCours(
      {int? page = 1, required int categorie, required int matiere}) async {
    try {
      final heade = await header();
      final response = await dio.get('cours?page=$page',
          options: Options(headers: heade),
          queryParameters: {
            'matiere_id': matiere,
            'categorie_id': categorie,
          });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
