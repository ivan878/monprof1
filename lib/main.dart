import 'package:get/get.dart';
import 'splash/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monprof/corps/utils/injectors.dart';
import 'package:monprof/splash/splash_controller.dart';
import 'package:monprof/auths/datas/services/user_storage.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  setupDependencies();
  Get.put(SplaController());

  UserLocalStorageService.logout();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MonProf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const SpashScreen(),
    );
  }
}
