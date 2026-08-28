import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/screens/prepa_login_screen.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/home/prepa_home_screen.dart';
import 'package:monprof/prepa/splash/prepa_splash_controller.dart';
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
  late final SplashController _controller;

  bool _isOpening = true;
  String? _openingError;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _controller = SplashController(
      authRepository: GetIt.instance<PrepaAuthRepository>(),
      userRepository: GetIt.instance<PrepaUserRepository>(),
    );
    _anim.forward();
    _openApp();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _openApp({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() {
        _isOpening = true;
        _openingError = null;
      });
    }

    // Laisse l'animation du splash visible au minimum 1,5 seconde, sans
    // retarder le travail du contrôleur.
    final opening = _controller.openApp();
    await Future.delayed(const Duration(milliseconds: 1500));
    final result = await opening;

    if (!mounted) return;

    switch (result.destination) {
      case SplashDestination.login:
        _goToLogin();
        return;
      case SplashDestination.home:
        _navigate(const PrepaHomeScreen());
        return;
      case SplashDestination.completeProfile:
        final user = result.user;
        if (user == null) {
          _showOpeningError();
          return;
        }
        _navigate(CompleteProfileScreen(user: user, isFirstSetup: true));
        return;
      case SplashDestination.connectionRequired:
        _showOpeningError(result.message);
        return;
    }
  }

  void _showOpeningError([String? message]) {
    setState(() {
      _isOpening = false;
      _openingError = message;
    });
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
              if (_isOpening)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _openingError?.isNotEmpty == true
                            ? _openingError!
                            : 'Une connexion est nécessaire pour cette première ouverture.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _openApp(showLoading: true),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Réessayer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
