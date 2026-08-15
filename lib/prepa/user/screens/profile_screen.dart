// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/utils/injectors.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/auth/data/repository/prepa_auth_repository.dart';
import 'package:monprof/prepa/auth/screens/prepa_login_screen.dart';
import 'package:monprof/prepa/subscription/screens/mes_codes_screen.dart';
import 'package:monprof/prepa/subscription/screens/mes_subscriptions_screen.dart';
import 'package:monprof/prepa/subscription/screens/mes_transactions_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/prepa/user/controllers/profile_controller.dart';
import 'package:provider/provider.dart';
import 'package:monprof/prepa/user/screens/settings_screen.dart';
import 'package:monprof/prepa/user/screens/update_password_screen.dart';
import 'package:page_transition/page_transition.dart';

class PrepaProfileScreen extends StatefulWidget {
  const PrepaProfileScreen({super.key});

  @override
  State<PrepaProfileScreen> createState() => _PrepaProfileScreenState();
}

class _PrepaProfileScreenState extends State<PrepaProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PrepaProfileController>().loadProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrepaProfileController>(
      builder: (context, controller, _) {
        if (controller.state.isLoading) {
          return const Scaffold(body: Loading());
        }

        if (controller.state.hasError) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
            body: ErrorPage(
              errorMessage:
                  controller.state.errorModel?.error ?? 'Erreur de chargement',
              reload: controller.loadProfile,
            ),
          );
        }

        final user = controller.state.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const SimpleText(
              text: 'Mon Profil',
              size: 20,
              weight: FontWeight.bold,
            ),
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Paramètres',
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            color: prepaPrimaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Avatar + nom ───────────────────────────────────────────────
                _AvatarSection(user: user),

                const SizedBox(height: 20),

                // ── Infos personnelles ─────────────────────────────────────────
                _SectionCard(
                  title: 'Informations',
                  children: [
                    if (user?.email != null)
                      _MenuRow(
                        icon: Icons.email_outlined,
                        label: user!.email!,
                        onTap: null,
                      ),
                    if (user?.phone != null)
                      _MenuRow(
                        icon: Icons.phone_outlined,
                        label: user!.phone!,
                        onTap: null,
                      ),
                    if (user?.roles.isNotEmpty == true)
                      _MenuRow(
                        icon: Icons.verified_user_outlined,
                        label: user!.roles.join(', '),
                        onTap: null,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Navigation ─────────────────────────────────────────────────
                _SectionCard(
                  title: 'Mes données',
                  children: [
                    _MenuRow(
                      icon: Icons.assignment_rounded,
                      label: 'Mes inscriptions',
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const MesSubscriptionsScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuRow(
                      icon: Icons.confirmation_number_rounded,
                      label: 'Mes codes',
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const MesCodesScreen(),
                          ),
                        );
                      },
                    ),
                    _MenuRow(
                      icon: Icons.receipt_long_rounded,
                      label: 'Historique transactions',
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const MesTransactionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Sécurité ───────────────────────────────────────────────────
                _SectionCard(
                  title: 'Sécurité',
                  children: [
                    _MenuRow(
                      icon: Icons.lock_outline_rounded,
                      label: 'Changer le mot de passe',
                      showArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const UpdatePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Déconnexion ────────────────────────────────────────────────
                DefaultButton(
                  text: 'Se déconnecter',
                  backgroundColor: Colors.red,
                  height: 50,
                  color: white,
                  onPressed: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) => showLogoutDialog(context);
}

/// Déconnexion : ferme la session, purge le stockage local (dont les vidéos
/// téléchargées) puis renvoie vers l'écran de connexion.
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _LogoutDialog(parentContext: context),
  );
}

class _LogoutDialog extends StatefulWidget {
  final BuildContext parentContext;
  const _LogoutDialog({required this.parentContext});

  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog> {
  bool _busy = false;

  Future<void> _confirm() async {
    setState(() => _busy = true);

    await GetIt.instance<PrepaAuthRepository>().logout();
    await resetSessionState();

    if (!mounted) return;
    Navigator.pop(context); // ferme la boîte de dialogue

    Notify.toastSuccess('Déconnecté');
    Navigator.pushAndRemoveUntil(
      widget.parentContext,
      PageTransition(
        type: PageTransitionType.fade,
        child: const PrepaLoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const SimpleText(
          text: 'Déconnexion',
          size: 17,
          weight: FontWeight.bold,
        ),
        content: _busy
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: prepaPrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SimpleText(
                      text: 'Suppression des données locales…',
                      size: 14,
                      color: onGrey300,
                    ),
                  ),
                ],
              )
            : const SimpleText(
                text: 'Vous serez déconnecté et les données téléchargées '
                    '(cours et vidéos) seront supprimées de cet appareil.',
                size: 14,
              ),
        actions: _busy
            ? null
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      SimpleText(text: 'Annuler', color: onGrey300, size: 14),
                ),
                TextButton(
                  onPressed: _confirm,
                  child: SimpleText(
                    text: 'Déconnecter',
                    color: Colors.red.shade600,
                    size: 14,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
      ),
    );
  }
}

// ── Widgets utilitaires ──────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final PrepaUser? user;

  const _AvatarSection({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: prepaPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SimpleText(
                text: (user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : '?'),
                size: 32,
                weight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SimpleText(
            text: user?.name ?? 'Utilisateur',
            size: 18,
            weight: FontWeight.bold,
            align: TextAlign.center,
          ),
          if (user?.email != null) ...[
            const SizedBox(height: 4),
            SimpleText(
              text: user!.email!,
              size: 13,
              color: onGrey300,
              align: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: SimpleText(
              text: title,
              size: 12,
              weight: FontWeight.w600,
              color: onGrey300,
              letterspacing: 0.5,
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showArrow;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: prepaPrimaryColor),
            const SizedBox(width: 14),
            Expanded(
              child: SimpleText(text: label, size: 14),
            ),
            if (showArrow)
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: onGrey300),
          ],
        ),
      ),
    );
  }
}
