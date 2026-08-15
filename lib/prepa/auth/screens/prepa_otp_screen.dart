// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/auth/controllers/prepa_otp_controller.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/data/services/prepa_auth_service.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/home/prepa_home_screen.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';
import 'package:monprof/prepa/user/screens/complete_profile_screen.dart';
import 'package:pinput/pinput.dart';

class PrepaOtpScreen extends StatefulWidget {
  final String otpSessionId;
  final String? email;
  final String? phone;
  final PrepaNotificationType currentChannel;
  final PrepaOtpFlow flow;
  final int? registerPassword;

  const PrepaOtpScreen({
    super.key,
    required this.otpSessionId,
    this.email,
    this.phone,
    required this.currentChannel,
    required this.flow,
    this.registerPassword,
  });

  @override
  State<PrepaOtpScreen> createState() => _PrepaOtpScreenState();
}

class _PrepaOtpScreenState extends State<PrepaOtpScreen> {
  late final PrepaOtpController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PrepaOtpController(
      repository: GetIt.instance<PrepaAuthRepository>(),
    );
    _ctrl.initialize(
      otpSessionId: widget.otpSessionId,
      email: widget.email,
      phone: widget.phone,
      currentChannel: widget.currentChannel,
      flow: widget.flow,
      registerPassword: widget.registerPassword,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Contact affiché selon le canal actif ──────────────────────────────────

  String _maskedContact() {
    switch (_ctrl.currentChannel) {
      case PrepaNotificationType.email:
        if (widget.email != null) return _maskEmail(widget.email!);
        break;
      case PrepaNotificationType.sms:
      case PrepaNotificationType.whatsapp:
        if (widget.phone != null) return _maskPhone(widget.phone!);
        break;
    }
    if (widget.email != null) return _maskEmail(widget.email!);
    if (widget.phone != null) return _maskPhone(widget.phone!);
    return '';
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name***@$domain';
    final visible = name.substring(0, 2);
    return '$visible${'*' * (name.length - 2)}@$domain';
  }

  String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return phone;
    final lastTwo = digits.substring(digits.length - 2);
    final prefix = phone.substring(0, phone.length - 2);
    return '$prefix**$lastTwo';
  }

  // ── Validation et navigation ───────────────────────────────────────────────

  Future<void> _onValidate() async {
    FocusScope.of(context).unfocus();
    await _ctrl.validateOtp();

    if (_ctrl.validateState.hasData) {
      Notify.toastSuccess(widget.flow == PrepaOtpFlow.login
          ? 'Connexion réussie !'
          : 'Compte créé avec succès !');

      _syncFcmToken();

      final userRepo = GetIt.instance<PrepaUserRepository>();
      final meState = await userRepo.getMe();
      final user = meState.hasData ? meState.data! : _ctrl.validateState.data!;

      final goToComplete = !user.hasProfileCompleted || !user.hasPassword;

      if (goToComplete) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                CompleteProfileScreen(user: user, isFirstSetup: true),
          ),
          (_) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PrepaHomeScreen()),
          (_) => false,
        );
      }
    } else if (_ctrl.validateState.hasError) {
      Notify.showFailure(
        context,
        _ctrl.validateState.errorModel?.error ?? 'Code incorrect',
      );
    }
  }

  Future<void> _syncFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await GetIt.instance<PrepaUserRepository>().updateFcmToken(token);
      }
    } catch (_) {}
  }

  // ── Switch canal ───────────────────────────────────────────────────────────

  Future<void> _onSwitchChannel(PrepaNotificationType newChannel) async {
    if (newChannel == _ctrl.currentChannel) return;
    await _ctrl.switchChannel(newChannel);
    if (_ctrl.resendState.hasError) {
      Notify.showFailure(
        context,
        _ctrl.resendState.errorModel?.error ?? 'Erreur lors du changement',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // ── AppBar personnalisée ───────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
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
                      const Spacer(),
                      _StepBar(totalSteps: 3, currentStep: 2),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // ── Icône Shield ─────────────────────────────────
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: prepaPrimaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: prepaPrimaryColor,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 15),

                        const SimpleText(
                          text: 'Verify Account',
                          size: 24,
                          weight: FontWeight.bold,
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        SimpleText(
                          text: 'Please enter the secure code sent to',
                          size: 14,
                          color: onGrey300,
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        SimpleText(
                          text: _maskedContact(),
                          size: 15,
                          weight: FontWeight.bold,
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // ── Saisie OTP ───────────────────────────────────
                        if (_ctrl.isSwitchingChannel)
                          const SizedBox(
                            height: 40,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: prepaPrimaryColor),
                            ),
                          )
                        else
                          Form(
                            key: _ctrl.formKey,
                            child: Pinput(
                              length: 6,
                              controller: _ctrl.otpController,
                              keyboardType: TextInputType.none,
                              showCursor: true,
                              autofocus: false,
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return 'Code incomplet';
                                }
                                return null;
                              },
                              defaultPinTheme: PinTheme(
                                width: 48,
                                height: 56,
                                textStyle: const TextStyle(
                                  color: prepaPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1.5),
                                ),
                              ),
                              focusedPinTheme: PinTheme(
                                width: 48,
                                height: 56,
                                textStyle: const TextStyle(
                                  color: prepaPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: prepaPrimaryColor, width: 2.5),
                                ),
                              ),
                              errorPinTheme: PinTheme(
                                width: 48,
                                height: 56,
                                textStyle: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.red, width: 2),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 15),

                        // ── Resend card ──────────────────────────────────
                        _ResendCard(
                          ctrl: _ctrl,
                          hasEmail: widget.email != null,
                          hasPhone: widget.phone != null,
                          onSwitchChannel: _onSwitchChannel,
                          onResend: () async {
                            await _ctrl.resendOtp();
                            if (_ctrl.resendState.hasError) {
                              Notify.showFailure(
                                context,
                                _ctrl.resendState.errorModel?.error ??
                                    'Erreur lors du renvoi',
                              );
                            } else {
                              Notify.toastSuccess('Code renvoyé !');
                            }
                          },
                        ),
                        const SizedBox(height: 15),

                        // ── Bouton Confirm ───────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _ctrl.validateState.isLoading ||
                                    _ctrl.isSwitchingChannel
                                ? null
                                : _onValidate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: prepaPrimaryColor,
                              disabledBackgroundColor:
                                  prepaPrimaryColor.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _ctrl.validateState.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const SimpleText(
                                    text: 'Confirm Verification',
                                    size: 16,
                                    weight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Clavier personnalisé ───────────────────────────────────
                _NumericKeyboard(
                  onDigit: _ctrl.appendDigit,
                  onBackspace: _ctrl.deleteDigit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Barre de progression ──────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const _StepBar({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final filled = i < currentStep;
        return Container(
          width: 32,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: filled ? prepaPrimaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ── Card Resend ───────────────────────────────────────────────────────────────

class _ResendCard extends StatelessWidget {
  final PrepaOtpController ctrl;
  final bool hasEmail;
  final bool hasPhone;
  final void Function(PrepaNotificationType) onSwitchChannel;
  final VoidCallback onResend;

  const _ResendCard({
    required this.ctrl,
    required this.hasEmail,
    required this.hasPhone,
    required this.onSwitchChannel,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final canSwitch = hasEmail && hasPhone;
    final otherChannel = ctrl.currentChannel == PrepaNotificationType.email
        ? PrepaNotificationType.sms
        : PrepaNotificationType.email;
    final otherLabel = ctrl.currentChannel == PrepaNotificationType.email
        ? 'phone number'
        : 'Email';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (ctrl.resendState.isLoading) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: prepaPrimaryColor, strokeWidth: 2),
            ),
          ] else if (!ctrl.canResend) ...[
            SimpleText(
              text: 'RESEND CODE IN',
              size: 11,
              color: onGrey300,
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined,
                    color: prepaPrimaryColor, size: 18),
                const SizedBox(width: 6),
                SimpleText(
                  text: ctrl.countdownDisplay,
                  size: 22,
                  weight: FontWeight.bold,
                  color: prepaPrimaryColor,
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: onResend,
              child: const SimpleText(
                text: 'Resend Code',
                size: 14,
                weight: FontWeight.bold,
                color: prepaPrimaryColor,
              ),
            ),
          ],

          if (canSwitch && ctrl.canResend) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: ctrl.isSwitchingChannel
                  ? null
                  : () => onSwitchChannel(otherChannel),
              child: SimpleText(
                text: 'Send via $otherLabel instead',
                size: 13,
                color: ctrl.isSwitchingChannel ? onGrey300 : prepaPrimaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Clavier numérique personnalisé ────────────────────────────────────────────

class _NumericKeyboard extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const _NumericKeyboard({
    required this.onDigit,
    required this.onBackspace,
  });

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _keys.map((row) {
          return Row(
            children: row.map((key) {
              if (key.isEmpty) return const Expanded(child: SizedBox());
              if (key == 'del') {
                return Expanded(
                  child: _KeyButton(
                    onTap: onBackspace,
                    child: const Icon(Icons.backspace_outlined, size: 22),
                  ),
                );
              }
              return Expanded(
                child: _KeyButton(
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () => onDigit(key),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _KeyButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Center(child: child),
      ),
    );
  }
}
