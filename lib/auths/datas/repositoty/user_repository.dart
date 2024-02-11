import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/services/user_services.dart';

class UserRepository {
  UserRepository({required this.service});

  UserService service;

  Future<Map<String, dynamic>> register(
      Users user, Eleve eleve, String password) async {
    try {
      final response = await service.register(user, eleve, password);
      if (response['status']) {
        return {
          'user': Users.fromJson(response['data']['user']),
          'eleve': Users.fromJson(response['data']['eleve']),
          'classe': Users.fromJson(response['data']['classe']),
        };
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await service.login(email, password);
      if (response['status']) {
        return {
          'user': Users.fromJson(response['data']['user']),
          'eleve': Users.fromJson(response['data']['eleve']),
          'classe': Users.fromJson(response['data']['classe']),
        };
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Classe>> getClasse() async {
    try {
      final response = await service.getClasse();
      if (response['status']) {
        return List.from((response['data'] as List)
            .map((json) => Classe.fromJson(json))
            .toList());
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
