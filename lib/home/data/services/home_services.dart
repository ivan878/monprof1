import 'package:dio/dio.dart';
import 'package:monprof/corps/api_service.dart';

class HomeService {
  final Dio dio;
  HomeService({required this.dio});

  Future<Map<String, dynamic>> getMatieres() async {
    try {
      final heade = await header();
      final response =
          await dio.get('matiere', options: Options(headers: heade));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCategorie() async {
    try {
      final heade = await header();
      final response =
          await dio.get('categorie', options: Options(headers: heade));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCategorieStatus() async {
    try {
      final heade = await header();
      final response =
          await dio.get('categorie/status', options: Options(headers: heade));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
