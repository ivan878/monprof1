// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
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
import 'package:monprof/prepa/auth/controllers/prepa_oauth_controller.dart';
import 'package:monprof/prepa/auth/controllers/prepa_register_controller.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';
import 'package:monprof/prepa/auth/screens/prepa_otp_screen.dart';
import 'package:monprof/prepa/common/widgets/country_phone_field.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/home/prepa_home_screen.dart';
import 'package:monprof/prepa/user/screens/complete_profile_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class PrepaRegisterScreen extends StatefulWidget {
  const PrepaRegisterScreen({super.key});

  @override
  State<PrepaRegisterScreen> createState() => _PrepaRegisterScreenState();
}

class _PrepaRegisterScreenState extends State<PrepaRegisterScreen> {
  late final PrepaRegisterController _ctrl;
  late final PrepaOAuthController _oAuthCtrl;
  bool _oAuthLoading = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = PrepaRegisterController(
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

  // ── OTP register handler ───────────────────────────────────────────────────

  Future<void> _onRegister() async {
    if (_ctrl.email.isEmpty && _ctrl.phone.isEmpty) {
      Notify.showFailure(
          context, 'Renseignez au moins un email ou un numéro de téléphone');
      return;
    }
    FocusScope.of(context).unfocus();
    await _ctrl.initiateRegister();

    if (_ctrl.initiateState.hasData) {
      final session = _ctrl.initiateState.data!;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PrepaOtpScreen(
            otpSessionId: session.otpSessionId,
            email: _ctrl.email.isNotEmpty ? _ctrl.email : null,
            phone: _ctrl.phone.isNotEmpty ? _ctrl.phone : null,
            currentChannel: _ctrl.defaultChannel,
            flow: PrepaOtpFlow.register,
            registerPassword: _ctrl.password,
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Form(
                    key: _ctrl.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo ─────────────────────────────────────────────────
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/concour-logo.jpeg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ── Titre ─────────────────────────────────────────────────
                        SimpleText(
                          text: 'Créer un compte',
                          size: 26,
                          weight: FontWeight.bold,
                        ),
                        const SizedBox(height: 6),
                        SimpleText(
                          text: 'Rejoignez la plateforme Prepa Concours',
                          size: 14,
                          color: onGrey300,
                        ),
                        const SizedBox(height: 24),

                        // ── Nom complet ───────────────────────────────────────────
                        TextFielApp(
                          controller: _ctrl.nameController,
                          hinText: 'Nom complet',
                          prefixIcon:
                              Icon(Icons.person_outline, color: onGrey300),
                          validator:
                              ValidationBuilder(requiredMessage: 'Nom requis')
                                  .minLength(2, 'Nom trop court')
                                  .build(),
                        ),
                        const SizedBox(height: 14),

                        // ── Email ─────────────────────────────────────────────────
                        TextFielApp(
                          controller: _ctrl.emailController,
                          hinText: 'Adresse email',
                          prefixIcon:
                              Icon(Icons.email_outlined, color: onGrey300),
                          inputType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Champ obligatoire";
                            }
                            return ValidationBuilder()
                                .email('Email invalide')
                                .build()(val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Téléphone ─────────────────────────────────────────────
                        CountryPhoneField(
                          controller: _ctrl.phoneController,
                          onDialCodeChanged: _ctrl.setDialCode,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Numéro de téléphone requis';
                            }
                            if (val.trim().length < 7) {
                              return 'Numéro trop court';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Code PIN ──────────────────────────────────────────────
                        _PinField(
                          controller: _ctrl.passwordController,
                          hintText: 'Créer un code PIN',
                          visible: _passwordVisible,
                          onToggle: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Code PIN requis';
                            }
                            if (v.trim().length < 6) {
                              return 'Minimum 6 chiffres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── Canal OTP ─────────────────────────────────────────────
                        SimpleText(
                          text: 'Recevoir le code de vérification par',
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 10),
                        _ContactTypeSelector(controller: _ctrl),
                        const SizedBox(height: 24),

                        // ── Bouton S'inscrire ─────────────────────────────────────
                        DefaultButton(
                          text: "S'inscrire",
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
                              : _onRegister,
                        ),
                        const SizedBox(height: 14),

                        // ── Acceptation des conditions ────────────────────────────
                        const _TermsNotice(),
                        const SizedBox(height: 20),

                        // ── Lien vers login ───────────────────────────────────────
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontFamily: 'Poppins', fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: "Déjà un compte ? ",
                                    style: TextStyle(color: onGrey300),
                                  ),
                                  const TextSpan(
                                    text: "Se connecter",
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Champ PIN avec toggle visibilité ─────────────────────────────────────────

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool visible;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PinField({
    required this.controller,
    required this.hintText,
    required this.visible,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFielApp(
      controller: controller,
      hinText: hintText,
      inputType: TextInputType.number,
      maxLines: 1,
      obscureTexte: !visible,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefixIcon: Icon(Icons.lock_outline, color: onGrey300),
      suffixIcon: IconButton(
        icon: Icon(
          visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: onGrey300,
          size: 20,
        ),
        onPressed: onToggle,
      ),
      validator: validator,
    );
  }
}

// ── Sélecteur canal ───────────────────────────────────────────────────────────

class _ContactTypeSelector extends StatelessWidget {
  final PrepaRegisterController controller;
  const _ContactTypeSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ChannelChip(
          label: 'Email',
          icon: Icons.email_outlined,
          selected: controller.contactType == RegisterContactType.email,
          onTap: () => controller.switchContactType(RegisterContactType.email),
        ),
        const SizedBox(width: 10),
        _ChannelChip(
          label: 'SMS',
          icon: Icons.sms_outlined,
          selected: controller.contactType == RegisterContactType.phone,
          onTap: () => controller.switchContactType(RegisterContactType.phone),
        ),
      ],
    );
  }
}

class _ChannelChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChannelChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? prepaPrimaryColor : grey300,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? prepaPrimaryColor : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : onGrey300),
            const SizedBox(width: 6),
            SimpleText(
              text: label,
              size: 13,
              weight: FontWeight.w600,
              color: selected ? Colors.white : onGrey300,
            ),
          ],
        ),
      ),
    );
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

// ── Acceptation des conditions ───────────────────────────────────────────────

/// Mention légale affichée sous le bouton d'inscription.
/// L'inscription vaut acceptation : les deux documents sont consultables
/// directement depuis les liens.
class _TermsNotice extends StatelessWidget {
  const _TermsNotice();

  // Mêmes adresses que l'écran Paramètres
  static const _termsUrl = 'https://prepa.mutrix.org/terms-of-service';
  static const _privacyUrl = 'https://prepa.mutrix.org/privacy-policy';

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      height: 1.5,
      color: onGrey300,
    );
    final link = base.copyWith(
      color: prepaPrimaryColor,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: base,
          children: [
            const TextSpan(text: 'En vous inscrivant, vous acceptez nos '),
            TextSpan(
              text: "Conditions d'utilisation",
              style: link,
              recognizer: TapGestureRecognizer()..onTap = () => _open(_termsUrl),
            ),
            const TextSpan(text: ' et nos '),
            TextSpan(
              text: 'Règles de confidentialité',
              style: link,
              recognizer: TapGestureRecognizer()
                ..onTap = () => _open(_privacyUrl),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
