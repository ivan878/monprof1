import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/auths/datas/services/user_services.dart';
import 'package:monprof/auths/logique_metier/login_controller.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';

void setupDependencies() {
  GetIt.instance.registerLazySingleton<Dio>(() => PublicAPI().dio);
  GetIt.instance.registerLazySingleton<UserService>(
      () => UserService(dio: GetIt.instance<Dio>()));
  GetIt.instance.registerLazySingleton<UserRepository>(
      () => UserRepository(service: GetIt.instance<UserService>()));
  GetIt.instance.registerLazySingleton<LoginController>(
      () => LoginController(repository: GetIt.instance<UserRepository>()));
}
