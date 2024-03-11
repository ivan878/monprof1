import 'package:dio/dio.dart';
import 'package:monprof/auths/datas/models/parents_model.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';

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
      final response = await dio.post('eleve/register',
          data: FormData.fromMap(data),
          options: Options(
            headers: {
              // 'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerParent(
      Users users, ParentModel parentModel, String password) async {
    try {
      final data = {
        ...users.toJson(),
        ...parentModel.toMap(),
        'password': password,
      };
      final response = await dio.post('parent/register',
          data: FormData.fromMap(data),
          options: Options(
            headers: {
              // 'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));
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
      final response = await dio.post('user/login',
          data: FormData.fromMap(data),
          options: Options(
            headers: {
              // 'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getClasse() async {
    try {
      final response = await dio.get('classe',
          options: Options(
            headers: {
              'Accept': 'application/json',
            },
          ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// fin
}
