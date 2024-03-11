import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/auths/datas/models/parents_model.dart';
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
          'eleve': Eleve.fromJson(response['data']['student']),
          'classe': Classe.fromJson(response['data']['classe']),
          'token': response['auth']['token']
        };
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> registerParent(
      Users user, ParentModel parentModel, String password) async {
    try {
      final response =
          await service.registerParent(user, parentModel, password);
      if (response['status']) {
        return {
          'user': Users.fromJson(response['data']['user']),
          'parent': ParentModel.fromMap(response['data']['parent']),
          'token': response['auth']['token']
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
        final Users usersAPI = Users.fromJson(response['data']['user']);
        return usersAPI.isParent
            ? {
                'user': usersAPI,
                'parent': ParentModel.fromMap(response['data']['parent']),
                'token': response['auth']['token']
              }
            : {
                'user': usersAPI,
                'eleve': Eleve.fromJson(response['data']['student']),
                'classe': Classe.fromJson(response['data']['classe']),
                'token': response['auth']['token']
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

  ///
}
