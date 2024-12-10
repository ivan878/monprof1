import 'dart:io';

import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/auths/datas/models/parents_model.dart';
import 'package:monprof/auths/datas/services/user_services.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/corps/utils/helper.dart';

class UserRepository {
  UserRepository({
    required this.service,
    required this.storage,
  });

  UserService service;
  UserLocalStorageService storage;

  Future<Map<String, dynamic>> register(
      Users user, Eleve eleve, String password) async {
    try {
      final response = await service.register(user, eleve, password);
      if (response['status']) {
        final token = response['auth']['token'];
        storage.storeToken(token);
        storage.storeRefreshToken(response['auth']['refresh_token']);
        storage.storeUser(Users.fromJson(response['data']['user']));
        storage.storeEleve(Eleve.fromJson(response['data']['student']));
        storage.storeClasse(Classe.fromJson(response['data']['classe']));
        return {
          'user': Users.fromJson(response['data']['user']),
          'eleve': Eleve.fromJson(response['data']['student']),
          'classe': Classe.fromJson(response['data']['classe']),
          'token': response['auth']['token'],
          'refresh_token': response['auth']['refresh_token']
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
        final token = response['auth']['token'];
        storage.storeToken(token);
        storage.storeRefreshToken(response['auth']['refresh_token']);
        storage.storeUser(Users.fromJson(response['data']['user']));
        storage.storeParent(ParentModel.fromMap(response['data']['parent']));
        return {
          'user': Users.fromJson(response['data']['user']),
          'parent': ParentModel.fromMap(response['data']['parent']),
          'token': response['auth']['token'],
          'refresh_token': response['auth']['refresh_token']
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
        final token = response['auth']['token'];
        storage.storeToken(token);
        storage.storeRefreshToken(response['auth']['refresh_token']);
        if (usersAPI.isParent) {
          storage.storeParent(ParentModel.fromMap(response['data']['parent']));
        } else {
          storage.storeEleve(Eleve.fromJson(response['data']['student']));
          storage.storeClasse(Classe.fromJson(response['data']['classe']));
        }
        storage.storeUser(usersAPI);
        // storage.storeEleve(Eleve.fromJson(response['data']['student']));
        // storage.storeClasse(Classe.fromJson(response['data']['classe']));
        // storage.storeParent(ParentModel.fromMap(response['data']['parent']));
        return usersAPI.isParent
            ? {
                'user': usersAPI,
                'parent': ParentModel.fromMap(response['data']['parent']),
                'token': response['auth']['token'],
                'refresh_token': response['auth']['refresh_token']
              }
            : {
                'user': usersAPI,
                'eleve': Eleve.fromJson(response['data']['student']),
                'classe': Classe.fromJson(response['data']['classe']),
                'token': response['auth']['token'],
                'refresh_token': response['auth']['refresh_token']
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

  Future<AppState<Users>> updateProfileImage(File file) async {
    try {
      final user = await service.updateProfileImage(file);
      return AppState(data: user, status: AppStatus.data);
    } catch (e) {
      printer(e);
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<OtpModel>> requestOTP(String phone) async {
    try {
      final response = await service.requestOTP(phone);
      return AppState(data: response, status: AppStatus.data);
    } catch (e) {
      printer(e);
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<bool>> verifyOTP(
      String verificationId, String otp, String phone) async {
    try {
      final response = await service.verifyOtp(verificationId, otp, phone);
      return AppState(data: response, status: AppStatus.data);
    } catch (e) {
      printer(e);
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<bool>> resetPassword(
      String phone, String otp, String type, String verificationId,
      {String? password}) async {
    try {
      final response = await service
          .resetPassword(phone, otp, type, verificationId, password: password);
      return AppState(data: response, status: AppStatus.data);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  ///
}
