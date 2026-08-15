import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/injectors.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/firebase_options.dart';
import 'package:monprof/notification/data/services/fcm_notification_services.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/controllers/concours_list_controller.dart';
import 'package:monprof/prepa/cours/controllers/matieres_controller.dart';
import 'package:monprof/prepa/home/home_controller.dart';
import 'package:monprof/prepa/splash/prepa_splash_screen.dart';
import 'package:monprof/prepa/subscription/controllers/mes_transactions_controller.dart';
import 'package:monprof/prepa/user/controllers/profile_controller.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  Intl.defaultLocale = 'fr_FR';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final hive = HiveService();
  await hive.init();
  GetIt.instance.registerSingleton<HiveService>(hive);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  await NotificationService().init();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    sound: true,
    badge: true,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await setupDependencies();
  runApp(const PrepaApp());
}

class PrepaApp extends StatelessWidget {
  const PrepaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: GetIt.instance<HomeController>()),
        ChangeNotifierProvider.value(
            value: GetIt.instance<ConcoursListController>()),
        ChangeNotifierProvider.value(
            value: GetIt.instance<PrepaProfileController>()),
        ChangeNotifierProvider.value(
            value: GetIt.instance<MesTransactionsController>()),
        ChangeNotifierProvider.value(
            value: GetIt.instance<MatieresController>()),
      ],
      child: OKToast(
        child: MaterialApp(
          title: 'Prepa Concours',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: prepaPrimaryColor),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          home: const _UnfocusWrapper(child: PrepaSplashScreen()),
        ),
      ),
    );
  }
}

class _UnfocusWrapper extends StatelessWidget {
  final Widget child;
  const _UnfocusWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
