import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:monprof/firebase_options.dart';
import 'package:monprof/i18n/app_localization.dart';
import 'package:monprof/notification/data/services/fcm_notification_services.dart';
import 'package:oktoast/oktoast.dart';
import 'splash/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monprof/corps/utils/injectors.dart';
import 'package:monprof/splash/splash_controller.dart';
// import 'package:monprof/auths/datas/services/user_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  await NotificationService().init();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    sound: true,
    badge: true,
  );
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await setupDependencies();
  final controller = Get.put(SplaController());
  await controller.checklocal();
  await controller.checkTheme();
  // UserLocalStorageService.logout();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        title: 'MonProf',
        debugShowCheckedModeBanner: false,
        locale: Get.find<SplaController>().langageModel.locale,
        fallbackLocale: const Locale('fr'),
        translationsKeys: AppLocalization.translationsKeys,
        themeMode: Get.find<SplaController>().mode,
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: const SpashScreen(),
      ),
    );
  }
}
