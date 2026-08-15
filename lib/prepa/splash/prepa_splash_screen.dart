import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/screens/prepa_login_screen.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/home/prepa_home_screen.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';
import 'package:monprof/prepa/user/screens/complete_profile_screen.dart';

class PrepaSplashScreen extends StatefulWidget {
  const PrepaSplashScreen({super.key});

  @override
  State<PrepaSplashScreen> createState() => _PrepaSplashScreenState();
}

class _PrepaSplashScreenState extends State<PrepaSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
    _checkAuth();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      // Vérifie la session Firebase — l'ID Token est géré automatiquement par le SDK.
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (firebaseUser == null) {
        _goToLogin();
        return;
      }

      // Session Firebase active → vérifie que le compte existe bien côté backend.
      final userRepo = GetIt.instance<PrepaUserRepository>();
      final meState = await userRepo.getMe();

      if (!mounted) return;

      if (meState.hasData) {
        final user = meState.data!;
        if (!user.hasProfileCompleted || !user.hasPassword) {
          _navigate(CompleteProfileScreen(user: user, isFirstSetup: true));
        } else {
          _navigate(const PrepaHomeScreen());
        }
      } else {
        // Firebase OK mais backend rejette → déconnexion complète.
        final authRepo = GetIt.instance<PrepaAuthRepository>();
        await authRepo.logout();
        _goToLogin();
      }
    } catch (e) {
      final authRepo = GetIt.instance<PrepaAuthRepository>();
      authRepo.logout();
      _goToLogin();
    }
  }

  void _goToLogin() => _navigate(const PrepaLoginScreen());

  void _navigate(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prepaPrimaryColor,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Prepa Concours',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Réussir ensemble',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
