// ignore: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monprof/UI/homeScreen.dart';
import 'package:monprof/UI/onboarding.dart';

import 'package:page_transition/page_transition.dart';

class SpashScreen extends StatefulWidget {
  const SpashScreen({Key? key}) : super(key: key);

  @override
  State<SpashScreen> createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft, child: const Onboarding()));
    });
    super.initState();
  }

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
