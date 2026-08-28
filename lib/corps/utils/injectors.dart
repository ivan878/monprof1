import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/device_identity.dart';
import 'package:monprof/prepa/cours/data/crypto/video_decryption_service.dart';
import 'package:monprof/corps/utils/local_storage/app_storage_cleaner.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/data/services/prepa_api_client.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';
import 'package:monprof/prepa/auth/data/services/prepa_oauth_service.dart';
import 'package:monprof/prepa/auth/data/services/prepa_token_storage.dart';
import 'package:monprof/prepa/concours/controllers/concours_list_controller.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';
import 'package:monprof/prepa/concours/data/services/concours_service.dart';
import 'package:monprof/prepa/cours/controllers/matieres_controller.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';
import 'package:monprof/prepa/cours/data/repository/video_key_repository.dart';
import 'package:monprof/prepa/cours/data/services/video_download_manager.dart';
import 'package:monprof/prepa/cours/data/services/cours_service.dart';
import 'package:monprof/prepa/home/home_controller.dart';
import 'package:monprof/prepa/subscription/controllers/mes_transactions_controller.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';
import 'package:monprof/prepa/subscription/data/services/subscription_service.dart';
import 'package:monprof/prepa/user/controllers/profile_controller.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';
import 'package:monprof/prepa/user/data/services/user_service.dart';

Future<void> setupDependencies() async {
  // Résolution anticipée de l'identifiant d'appareil : sans attendre, pour ne
  // pas retarder le démarrage — la première requête l'attendra si nécessaire.
  unawaited(DeviceIdentity.instance.warmUp());

  // Une fermeture brutale peut laisser une copie déchiffrée dans le répertoire
  // temporaire : elle ne doit pas survivre au redémarrage.
  unawaited(VideoDecryptionService.instance.purgeAll());

  // ── Stockage sécurisé ─────────────────────────────────────────────────────
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  GetIt.instance.registerSingleton<PrepaTokenStorage>(
    PrepaTokenStorage(secureStorage),
  );

  // Purge de toutes les données locales (déconnexion).
  GetIt.instance.registerLazySingleton<AppStorageCleaner>(
    () => AppStorageCleaner(
      hiveService: GetIt.instance<HiveService>(),
      secureStorage: secureStorage,
    ),
  );

  // ── HTTP client & Auth ────────────────────────────────────────────────────
  // Le Bearer token est l'ID Token Firebase (géré par Firebase SDK).
  GetIt.instance.registerLazySingleton<PrepaApiClient>(
    () => PrepaApiClient(),
  );
  GetIt.instance.registerLazySingleton<PrepaAuthService>(
    () => PrepaAuthService(dio: GetIt.instance<PrepaApiClient>().dio),
  );
  GetIt.instance.registerLazySingleton<PrepaOAuthService>(
    () => PrepaOAuthService(dio: GetIt.instance<PrepaApiClient>().dio),
  );
  GetIt.instance.registerLazySingleton<PrepaAuthRepository>(
    () => PrepaAuthRepository(
      service: GetIt.instance<PrepaAuthService>(),
      tokenStorage: GetIt.instance<PrepaTokenStorage>(),
      oAuthService: GetIt.instance<PrepaOAuthService>(),
      storageCleaner: GetIt.instance<AppStorageCleaner>(),
    ),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  GetIt.instance.registerLazySingleton<ConcoursService>(
    () => ConcoursService(dio: GetIt.instance<PrepaApiClient>().dio),
  );
  GetIt.instance.registerLazySingleton<ConcoursRepository>(
    () => ConcoursRepository(service: GetIt.instance<ConcoursService>()),
  );

  GetIt.instance.registerLazySingleton<PrepaCoursService>(
    () => PrepaCoursService(dio: GetIt.instance<PrepaApiClient>().dio),
  );
  GetIt.instance.registerLazySingleton<PrepaCoursRepository>(
    () => PrepaCoursRepository(service: GetIt.instance<PrepaCoursService>()),
  );

  // Téléchargement des vidéos avec reprise après interruption.
  GetIt.instance.registerLazySingleton<VideoDownloadManager>(
    () => VideoDownloadManager(
      dio: GetIt.instance<PrepaApiClient>().dio,
      hiveService: GetIt.instance<HiveService>(),
      coursService: GetIt.instance<PrepaCoursService>(),
    ),
  );

  // Clés de déchiffrement des vidéos — mises en coffre pour la lecture hors ligne.
  GetIt.instance.registerLazySingleton<VideoKeyRepository>(
    () => VideoKeyRepository(
      service: GetIt.instance<PrepaCoursService>(),
      secureStorage: secureStorage,
    ),
  );

  GetIt.instance.registerLazySingleton<SubscriptionService>(
    () => SubscriptionService(dio: GetIt.instance<PrepaApiClient>().dio),
  );
  GetIt.instance.registerLazySingleton<SubscriptionRepository>(
    () =>
        SubscriptionRepository(service: GetIt.instance<SubscriptionService>()),
  );

  GetIt.instance.registerLazySingleton<PrepaUserService>(
    () => PrepaUserService(dio: GetIt.instance<PrepaApiClient>().dio),
  );
  GetIt.instance.registerLazySingleton<PrepaUserRepository>(
    () => PrepaUserRepository(service: GetIt.instance<PrepaUserService>()),
  );

  // ── Singleton controllers ─────────────────────────────────────────────────
  // Construits dans la fabrique (et non capturés) pour que
  // `resetSessionState()` puisse en recréer des instances vierges.
  GetIt.instance.registerLazySingleton<HomeController>(
    () => HomeController(
      concoursRepository: GetIt.instance<ConcoursRepository>(),
      subscriptionRepository: GetIt.instance<SubscriptionRepository>(),
      prepaAuthRepository: GetIt.instance<PrepaAuthRepository>(),
      hiveService: GetIt.instance<HiveService>(),
    ),
  );

  GetIt.instance.registerLazySingleton<ConcoursListController>(
    () => ConcoursListController(
      repository: GetIt.instance<ConcoursRepository>(),
      hiveService: GetIt.instance<HiveService>(),
    ),
  );

  GetIt.instance.registerLazySingleton<PrepaProfileController>(
    () => PrepaProfileController(
      repository: GetIt.instance<PrepaUserRepository>(),
      hiveService: GetIt.instance<HiveService>(),
    ),
  );

  GetIt.instance.registerLazySingleton<MesTransactionsController>(
    () => MesTransactionsController(
      repository: GetIt.instance<SubscriptionRepository>(),
    ),
  );

  GetIt.instance.registerLazySingleton<MatieresController>(
    () => MatieresController(
      repository: GetIt.instance<PrepaCoursRepository>(),
      hiveService: GetIt.instance<HiveService>(),
    ),
  );
}

/// Recrée les contrôleurs singletons pour qu'aucune donnée du compte
/// précédent ne subsiste en mémoire après une déconnexion.
Future<void> resetSessionState() async {
  final getIt = GetIt.instance;
  await getIt.resetLazySingleton<HomeController>();
  await getIt.resetLazySingleton<ConcoursListController>();
  await getIt.resetLazySingleton<PrepaProfileController>();
  await getIt.resetLazySingleton<MesTransactionsController>();
  await getIt.resetLazySingleton<MatieresController>();
}
