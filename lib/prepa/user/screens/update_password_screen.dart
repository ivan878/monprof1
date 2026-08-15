// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/user/controllers/update_password_controller.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final UpdatePasswordController _ctrl;

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void initState() {
    super.initState();
    _ctrl = UpdatePasswordController(
      repository: GetIt.instance<PrepaUserRepository>(),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        if (_ctrl.state.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Notify.toastSuccess('Mot de passe modifié avec succès !');
            Navigator.pop(context);
            _ctrl.reset();
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const SimpleText(
              text: 'Changer le mot de passe',
              size: 18,
              weight: FontWeight.bold,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Info ──────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: prepaPrimaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: prepaPrimaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: prepaPrimaryColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SimpleText(
                            text:
                                'Le mot de passe doit être un code PIN numérique.',
                            size: 13,
                            color: prepaPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Ancien mot de passe ────────────────────────────────────
                  SimpleText(
                    text: 'Mot de passe actuel',
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  TextFielApp(
                    controller: _oldPasswordController,
                    hinText: 'Code PIN actuel',
                    inputType: TextInputType.number,
                    obscureTexte: !_showOld,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showOld
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: onGrey300,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showOld = !_showOld),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: Colors.grey, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Entrez votre mot de passe actuel';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Nouveau mot de passe ───────────────────────────────────
                  SimpleText(
                    text: 'Nouveau mot de passe',
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  TextFielApp(
                    controller: _newPasswordController,
                    hinText: 'Nouveau code PIN',
                    inputType: TextInputType.number,
                    obscureTexte: !_showNew,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNew
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: onGrey300,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showNew = !_showNew),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: Colors.grey, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Entrez un nouveau mot de passe';
                      }
                      if (v.trim().length < 4) {
                        return 'Le code PIN doit faire au moins 4 chiffres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Confirmation ───────────────────────────────────────────
                  SimpleText(
                    text: 'Confirmer le mot de passe',
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  TextFielApp(
                    controller: _confirmPasswordController,
                    hinText: 'Confirmer le code PIN',
                    inputType: TextInputType.number,
                    obscureTexte: !_showConfirm,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirm
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: onGrey300,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showConfirm = !_showConfirm),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: Colors.grey, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Confirmez votre nouveau mot de passe';
                      }
                      if (v.trim() != _newPasswordController.text.trim()) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // ── Message d'erreur ───────────────────────────────────────
                  if (_ctrl.state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SimpleText(
                          text: _ctrl.state.errorModel?.error ??
                              'Une erreur est survenue',
                          color: Colors.red.shade700,
                          size: 13,
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // ── Bouton confirmer ───────────────────────────────────────
                  DefaultButton(
                    text: 'Confirmer',
                    onPressed: _ctrl.state.isLoading
                        ? null
                        : () => _submit(),
                    wdiget: _ctrl.state.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final oldPin = int.tryParse(_oldPasswordController.text.trim()) ?? 0;
    final newPin = int.tryParse(_newPasswordController.text.trim()) ?? 0;

    _ctrl.updatePassword(oldPassword: oldPin, newPassword: newPin);
  }
}
