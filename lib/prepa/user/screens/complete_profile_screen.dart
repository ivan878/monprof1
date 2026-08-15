// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/app_text_field.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/common/widgets/country_phone_field.dart';
import 'package:monprof/prepa/home/prepa_home_screen.dart';
import 'package:monprof/prepa/user/controllers/complete_profile_controller.dart';
import 'package:monprof/prepa/user/data/repository/user_repository.dart';

class CompleteProfileScreen extends StatefulWidget {
  final PrepaUser? user;
  final bool isFirstSetup;

  const CompleteProfileScreen({
    super.key,
    this.user,
    this.isFirstSetup = false,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final CompleteProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CompleteProfileController(
      repository: GetIt.instance<PrepaUserRepository>(),
      initialUser: widget.user,
      hasPassword: widget.user?.hasPassword,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        if (_ctrl.updateState.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Notify.toastSuccess('Profil mis à jour avec succès !');
            if (widget.isFirstSetup) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PrepaHomeScreen()),
                (_) => false,
              );
            } else {
              Navigator.pop(context, _ctrl.updateState.data);
            }
          });
        }

        return Scaffold(
          backgroundColor: grey300,
          appBar: widget.isFirstSetup
              ? null
              : AppBar(
                  title: const SimpleText(
                    text: 'Complete Profile',
                    size: 19,
                    weight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  centerTitle: true,
                  backgroundColor: prepaPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
          body: Form(
            key: _ctrl.formKey,
            child: ListView(
              padding: EdgeInsets.only(
                top: widget.isFirstSetup
                    ? MediaQuery.of(context).padding.top + 24
                    : 0,
                bottom: 32,
                left: 0,
                right: 0,
              ),
              children: [
                _AvatarPicker(controller: _ctrl, user: widget.user),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label(text: 'Full Name'),
                      const SizedBox(height: 8),
                      IgnorePointer(
                        ignoring: widget.user?.name.isNotEmpty == true,
                        child: TextFielApp(
                          controller: _ctrl.nameController,
                          hinText: 'Jean Dupont',
                          inputType: TextInputType.name,
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: widget.user?.name.isNotEmpty == true
                                ? Colors.grey.shade400
                                : Colors.grey,
                          ),
                          filled: widget.user?.name.isNotEmpty == true,
                          fillColor: widget.user?.name.isNotEmpty == true
                              ? Colors.grey.shade100
                              : null,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Veuillez saisir votre nom complet';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (widget.user?.name.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 4),
                          child: SimpleText(
                            text: 'Nom fourni par votre compte Google/Apple.',
                            size: 11,
                            color: onGrey300,
                          ),
                        ),

                      const SizedBox(height: 18),

                      _Label(text: 'Email Address'),
                      const SizedBox(height: 8),
                      TextFielApp(
                        controller: TextEditingController(
                            text: widget.user?.email ?? ''),
                        hinText: 'jean.dupont@example.com',
                        inputType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        validator: null,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 4),
                        child: SimpleText(
                          text: 'Email cannot be changed after registration.',
                          size: 11,
                          color: onGrey300,
                        ),
                      ),

                      const SizedBox(height: 18),

                      _Label(text: 'Numéro de téléphone'),
                      const SizedBox(height: 8),
                      CountryPhoneField(
                        controller: _ctrl.phoneController,
                        initialPhone: widget.user?.phone,
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

                      if (!_ctrl.hasPassword) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(),
                        ),

                        _Label(text: 'Créer un code PIN'),
                        const SizedBox(height: 8),
                        _PasswordField(
                          controller: _ctrl.passwordController,
                          hintText: '••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Code PIN requis';
                            }
                            if (v.trim().length < 6) {
                              return 'Code PIN minimum 6 chiffres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _Label(text: 'Confirmer le code PIN'),
                        const SizedBox(height: 8),
                        _PasswordField(
                          controller: _ctrl.confirmPasswordController,
                          hintText: '••••••',
                          prefixIcon: Icons.lock_reset_rounded,
                          validator: (v) {
                            if (_ctrl.passwordController.text
                                    .trim()
                                    .isNotEmpty &&
                                v != _ctrl.passwordController.text.trim()) {
                              return 'Les codes PIN ne correspondent pas';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),
                      ] else
                        const SizedBox(height: 32),

                      if (_ctrl.updateState.hasError ||
                          _ctrl.uploadState.hasError ||
                          _ctrl.setPasswordState.hasError) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SimpleText(
                            text: _ctrl.updateState.errorModel?.error ??
                                _ctrl.uploadState.errorModel?.error ??
                                _ctrl.setPasswordState.errorModel?.error ??
                                'Une erreur est survenue',
                            color: Colors.red.shade700,
                            size: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      DefaultButton(
                        onPressed:
                            _ctrl.isSaving ? null : () => _ctrl.saveProfile(),
                        backgroundColor: prepaPrimaryColor,
                        wdiget: _ctrl.isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  SimpleText(
                                    text: 'Save Profile',
                                    color: Colors.white,
                                    size: 16,
                                    weight: FontWeight.bold,
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 14),

                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 12, color: onGrey300, height: 1.5),
                          children: [
                            const TextSpan(
                                text:
                                    'By completing your profile, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: prepaPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
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

// ── Avatar picker ─────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final CompleteProfileController controller;
  final PrepaUser? user;

  const _AvatarPicker({required this.controller, this.user});

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  )),
              const SizedBox(height: 16),
              ListTile(
                leading:
                    Icon(Icons.camera_alt_rounded, color: prepaPrimaryColor),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library_rounded, color: prepaPrimaryColor),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      controller.setLocalImage(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFirebasePhoto = user?.profilePictureUrl != null;
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: hasFirebasePhoto ? null : () => _pickImage(context),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: controller.localImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(controller.localImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : user?.profilePictureUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user!.profilePictureUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: controller.localImagePath == null &&
                          user?.profilePictureUrl == null
                      ? Center(
                          child: SimpleText(
                            text: (user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?'),
                            size: 38,
                            weight: FontWeight.bold,
                            color: prepaPrimaryColor,
                          ),
                        )
                      : null,
                ),
                if (!hasFirebasePhoto)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: prepaPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 16),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SimpleText(
            text: 'Your Profile Picture',
            size: 17,
            weight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          SimpleText(
            text: 'Help mentors and peers recognize you',
            size: 13,
            color: onGrey300,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Champ mot de passe ────────────────────────────────────────────────────────

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFielApp(
      controller: widget.controller,
      hinText: widget.hintText,
      maxLines: 1,
      inputType: TextInputType.number,
      obscureTexte: !_visible,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefixIcon: Icon(widget.prefixIcon, color: Colors.grey),
      suffixIcon: IconButton(
        icon: Icon(
          _visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: onGrey300,
          size: 20,
        ),
        onPressed: () => setState(() => _visible = !_visible),
      ),
      validator: widget.validator,
    );
  }
}

// ── Label ─────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return SimpleText(
      text: text,
      size: 14,
      weight: FontWeight.bold,
    );
  }
}
