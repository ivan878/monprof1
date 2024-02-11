import 'package:dio/dio.dart';
import 'package:monprof/commons/constantes.dart';

import '../../domains/modeles/students.dart';
import '../../domains/modeles/user.dart';

class UserService {
  Future<Response> register(User user, Student student) async {
    final Dio dio = Dio();
    Map<String, dynamic> data = {...user.toJson(), ...student.toJson()};
    final FormData formData = FormData.fromMap(data);
    final response = await dio.post("$baseUrl/eleve/register", data: formData);
    return response;
  }

  Future<Response> login(String email, String password) async {
    final Dio dio = Dio();
    Map<String, dynamic> data = {'email': email, 'password': password};
    final FormData formData = FormData.fromMap(data);
    final response = await dio.post("$baseUrl/eleve/login", data: formData);
    return response;
  }

  //
}
