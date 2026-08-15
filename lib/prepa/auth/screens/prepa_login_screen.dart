// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/auth/controllers/prepa_login_controller.dart';
import 'package:monprof/prepa/auth/controllers/prepa_oauth_controller.dart';
import 'package:monprof/prepa/common/widgets/country_phone_field.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';
import 'package:monprof/prepa/auth/screens/prepa_otp_screen.dart';
import 'package:monprof/prepa/auth/screens/prepa_register_screen.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/home/prepa_home_screen.dart';
import 'package:monprof/prepa/user/screens/complete_profile_screen.dart';
import 'package:page_transition/page_transition.dart';

class PrepaLoginScreen extends StatefulWidget {
  const PrepaLoginScreen({super.key});

  @override
  State<PrepaLoginScreen> createState() => _PrepaLoginScreenState();
}

class _PrepaLoginScreenState extends State<PrepaLoginScreen> {
  late final PrepaLoginController _ctrl;
  late final PrepaOAuthController _oAuthCtrl;
  bool _oAuthLoading = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = PrepaLoginController(
      repository: GetIt.instance<PrepaAuthRepository>(),
    );
    _oAuthCtrl = PrepaOAuthController(
      repository: GetIt.instance<PrepaAuthRepository>(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── OAuth handlers ─────────────────────────────────────────────────────────

  Future<void> _onGoogle() async {
    setState(() => _oAuthLoading = true);
    await _oAuthCtrl.signInWithGoogle();
    if (!mounted) return;
    setState(() => _oAuthLoading = false);
    _navigateAfterOAuth();
  }

  Future<void> _onApple() async {
    setState(() => _oAuthLoading = true);
    await _oAuthCtrl.signInWithApple();
    if (!mounted) return;
    setState(() => _oAuthLoading = false);
    _navigateAfterOAuth();
  }

  void _navigateAfterOAuth() {
    final state = _oAuthCtrl.oAuthState;
    if (state.hasData) {
      final user = state.data!;
      if (!user.hasProfileCompleted || !user.hasPassword) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: CompleteProfileScreen(user: user, isFirstSetup: true),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const PrepaHomeScreen(),
          ),
        );
      }
    } else if (state.hasError) {
      Notify.showFailure(
        context,
        state.errorModel?.error ?? 'Erreur de connexion sociale',
      );
    }
  }

  // ── OTP login handler ──────────────────────────────────────────────────────

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();
    await _ctrl.initiateLogin();

    if (_ctrl.initiateState.hasData) {
      final session = _ctrl.initiateState.data!;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PrepaOtpScreen(
            otpSessionId: session.otpSessionId,
            email: _ctrl.isEmail ? _ctrl.contact : null,
            phone: _ctrl.isEmail ? null : _ctrl.contact,
            currentChannel: _ctrl.defaultChannel,
            flow: PrepaOtpFlow.login,
          ),
        ),
      );
    } else if (_ctrl.initiateState.hasError) {
      Notify.showFailure(
        context,
        _ctrl.initiateState.errorModel?.error ?? 'Une erreur est survenue',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _ctrl.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo ─────────────────────────────────────────────────
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/concour-logo.jpeg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Titre ─────────────────────────────────────────────────
                    SimpleText(
                      text: 'Connexion',
                      size: 26,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(height: 6),
                    SimpleText(
                      text: 'Entrez votre identifiant pour recevoir un code',
                      size: 14,
                      color: onGrey300,
                    ),
                    const SizedBox(height: 24),

                    // ── Toggle Email / Téléphone ──────────────────────────────
                    _IdentifierToggle(controller: _ctrl),
                    const SizedBox(height: 18),

                    // ── Champ contact ─────────────────────────────────────────
                    _ContactField(controller: _ctrl),
                    const SizedBox(height: 16),

                    // ── Mot de passe PIN ──────────────────────────────────────
                    TextFielApp(
                      controller: _ctrl.passwordController,
                      hinText: 'Code PIN',
                      inputType: TextInputType.number,
                      maxLines: 1,
                      lenght: 6,
                      obscureTexte: !_passwordVisible,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      prefixIcon: Icon(Icons.lock_outline, color: onGrey300),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: onGrey300,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _passwordVisible = !_passwordVisible),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Code PIN requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Bouton Continuer ──────────────────────────────────────
                    DefaultButton(
                      text: 'Continuer',
                      backgroundColor: prepaPrimaryColor,
                      wdiget: _ctrl.initiateState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : null,
                      onPressed: _ctrl.initiateState.isLoading
                          ? null
                          : _onContinue,
                    ),
                    const SizedBox(height: 20),

                    // ── Lien vers inscription ─────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const PrepaRegisterScreen(),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Pas encore de compte ? ",
                                style: TextStyle(color: onGrey300),
                              ),
                              const TextSpan(
                                text: "S'inscrire",
                                style: TextStyle(
                                  color: prepaPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Séparateur OU ─────────────────────────────────────────
                    const _OrDivider(),
                    const SizedBox(height: 20),

                    // ── Bouton Google ─────────────────────────────────────────
                    _SocialButton(
                      label: 'Continuer avec Google',
                      icon: FontAwesomeIcons.google,
                      iconColor: const Color(0xFFDB4437),
                      onPressed: _oAuthLoading ? null : _onGoogle,
                      isLoading: _oAuthLoading,
                    ),
                    const SizedBox(height: 12),

                    // ── Bouton Apple ──────────────────────────────────────────
                    _SocialButton(
                      label: 'Continuer avec Apple',
                      icon: FontAwesomeIcons.apple,
                      iconColor: Colors.black87,
                      onPressed: _oAuthLoading ? null : _onApple,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Toggle Email / Téléphone ──────────────────────────────────────────────────

class _IdentifierToggle extends StatelessWidget {
  final PrepaLoginController controller;
  const _IdentifierToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: grey300,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleButton(
            label: 'Email',
            icon: Icons.email_outlined,
            isSelected: controller.isEmail,
            onTap: () =>
                controller.switchIdentifierType(LoginIdentifierType.email),
          ),
          _ToggleButton(
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            isSelected: !controller.isEmail,
            onTap: () =>
                controller.switchIdentifierType(LoginIdentifierType.phone),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? prepaPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : onGrey300,
              ),
              const SizedBox(width: 6),
              SimpleText(
                text: label,
                size: 14,
                weight: FontWeight.w600,
                color: isSelected ? Colors.white : onGrey300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Champ de contact ──────────────────────────────────────────────────────────

class _ContactField extends StatelessWidget {
  final PrepaLoginController controller;
  const _ContactField({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isEmail) {
      return TextFielApp(
        key: const ValueKey('email'),
        controller: controller.contactController,
        hinText: 'Votre adresse email',
        prefixIcon: Icon(Icons.email_outlined, color: onGrey300),
        inputType: TextInputType.emailAddress,
        validator: ValidationBuilder(requiredMessage: 'Email requis')
            .email('Email invalide')
            .build(),
      );
    } else {
      return CountryPhoneField(
        key: const ValueKey('phone'),
        controller: controller.contactController,
        onDialCodeChanged: controller.setDialCode,
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Numéro requis';
          if (val.trim().length < 7) return 'Numéro trop court';
          return null;
        },
      );
    }
  }
}

// ── Séparateur "OU" ───────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SimpleText(text: 'OU', size: 13, color: onGrey300),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

// ── Bouton social ─────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: prepaPrimaryColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 12),
                  SimpleText(
                    text: label,
                    size: 15,
                    weight: FontWeight.w600,
                  ),
                ],
              ),
      ),
    );
  }
}
