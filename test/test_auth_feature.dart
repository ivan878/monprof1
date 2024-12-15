import 'dart:io';

import 'package:dio/src/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monprof/auths/datas/models/classe_model.dart';
import 'package:monprof/auths/datas/models/eleve_modele.dart';
import 'package:monprof/auths/datas/models/otp_model.dart';
import 'package:monprof/auths/datas/models/parents_model.dart';
import 'package:monprof/auths/datas/models/user_modele.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
import 'package:monprof/auths/datas/services/user_services.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';
import 'package:monprof/auths/logique_metier/login_controller.dart';
import 'package:monprof/auths/logique_metier/register_controller.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/helper.dart';

class BadMockUserService implements UserService {
  @override
  Dio dio = API().dio;

  @override
  Future<Map<String, dynamic>> getClasse() async {
    return (await dio.get('classe')).data;
    // throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> register(
      Users users, Eleve eleve, String password) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> registerParent(
      Users users, ParentModel parentModel, String password) {
    // TODO: implement registerParent
    throw UnimplementedError();
  }

  @override
  Future updateToken() {
    // TODO: implement updateToken
    throw UnimplementedError();
  }

  @override
  Future<OtpModel> requestOTP(String phone) {
    // TODO: implement requestOTP
    throw UnimplementedError();
  }

  @override
  Future<bool> resetPassword(
      String phone, String otp, String type, String verificationId,
      {String? password}) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<Users> updateProfileImage(File file) {
    // TODO: implement updateProfileImage
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyOtp(String verificationId, String code, String phone) {
    // TODO: implement verifyOtp
    throw UnimplementedError();
  }
}

class MockUserService extends Mock implements UserService {}

class MockLocalStorageService extends Mock implements UserLocalStorageService {}

void main() {
  late LoginController loginController;
  late RegisterController registerController;
  late UserRepository userRepository;
  late MockUserService mockUserService;
  late MockLocalStorageService mockLocalStorageService;

  setUp(() {
    mockUserService = MockUserService();
    mockLocalStorageService = MockLocalStorageService();
    userRepository = UserRepository(
        service: mockUserService, storage: mockLocalStorageService);
    registerController = RegisterController(repository: userRepository);
    loginController = LoginController(repository: userRepository);
  });

  test("Test d'initialisation du controller de création de compte", () {
    expect(registerController.classeState,
        AppState<List<Classe>?>(status: AppStatus.loading));
    expect(registerController.state, AppState());
  });

  test("Teste de récupération des classes dans le login", () {
    expect(registerController.classeState,
        AppState<List<Classe>?>(status: AppStatus.loading));
    registerController.getClasse();
    printer(registerController.classeState.data);
    expect(registerController.classeState.data.runtimeType, List<Classe>);
  });
}
