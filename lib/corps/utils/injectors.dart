import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/home/data/services/home_services.dart';
import 'package:monprof/cours/data/services/cours_service.dart';
import 'package:monprof/auths/datas/services/user_services.dart';
import 'package:monprof/home/data/repository/home_repository.dart';
import 'package:monprof/auths/logique_metier/login_controller.dart';
import 'package:monprof/cours/data/repository/cours_repository.dart';
import 'package:monprof/auths/datas/repositoty/user_repository.dart';
import 'package:monprof/paiements/datas/services/paiements_services.dart';
import 'package:monprof/paiements/datas/reposytory/paiement_ripository.dart';
import 'package:monprof/questions/data/repository/question_repository.dart';
import 'package:monprof/questions/data/services/question_services.dart';

void setupDependencies() {
  GetIt.instance.registerLazySingleton<Dio>(
    () => PublicAPI().dio,
    // instanceName: 'public',
  );
  // GetIt.instance.registerLazySingleton<Dio>(
  //   () => API().dio,
  //   // instanceName: "private",
  // );
  GetIt.instance.registerLazySingleton<UserService>(
    () => UserService(dio: GetIt.instance<Dio>()),
  );

  GetIt.instance.registerLazySingleton<UserRepository>(
      () => UserRepository(service: GetIt.instance<UserService>()));
  GetIt.instance.registerLazySingleton<LoginController>(
      () => LoginController(repository: GetIt.instance<UserRepository>()));

  // Home Injector

  GetIt.instance.registerLazySingleton<HomeService>(
    () => HomeService(dio: GetIt.instance<Dio>()),
  );
  GetIt.instance.registerLazySingleton<HomeRepository>(
    () => HomeRepository(service: GetIt.instance<HomeService>()),
  );

  /// Cours Injector

  GetIt.instance.registerLazySingleton<CoursService>(
    () => CoursService(dio: GetIt.instance<Dio>()),
  );
  GetIt.instance.registerLazySingleton<CoursRepository>(
    () => CoursRepository(service: GetIt.instance<CoursService>()),
  );

  // Paiements

  GetIt.instance.registerLazySingleton<PaiementServices>(
    () => PaiementServices(GetIt.instance<Dio>()),
  );
  GetIt.instance.registerLazySingleton<PaiementRepository>(
    () => PaiementRepository(services: GetIt.instance<PaiementServices>()),
  );
  // Question

  GetIt.instance.registerLazySingleton<QuestionService>(
    () => QuestionService(dio:GetIt.instance<Dio>()),
  );
  GetIt.instance.registerLazySingleton<QuestionRepository>(
    () => QuestionRepository( GetIt.instance<QuestionService>()),
  );
}
