import 'package:architecture/auths/datas/models/eleve_modele.dart';
import 'package:architecture/auths/datas/models/user_modele.dart';
import 'package:dio/dio.dart';

class UserService {
  Dio dio;
  UserService({required this.dio});

  Future<Map<String, dynamic>> register(
      Users users, Eleve eleve, String password) async {
    try {
      final data = {
        ...users.toJson(),
        ...eleve.toJson(),
        'password': password,
      };
      final response = await dio.post('eleve/register', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };
      final response = await dio.post('eleve/login', data: data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getClasse() async {
    try {
      final response = await dio.get('classe');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// fin
}
