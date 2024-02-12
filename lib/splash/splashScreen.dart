import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:monprof/UI/homeScreen.dart';
import 'package:monprof/UI/onboarding.dart';
import 'package:monprof/UI/avantPageScreen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monprof/splash/splash_controller.dart';
import 'package:monprof/auths/presentation/login-screen.dart';
// ignore_for_file: file_names

class SpashScreen extends StatefulWidget {
  const SpashScreen({Key? key}) : super(key: key);

  @override
  State<SpashScreen> createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      Get.find<SplaController>().checkUser().then((value) {
        if (value == null) {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const LoginScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const Home(),
            ),
          );
        }
      });
    });
    super.initState();
  }

  chekUser() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
