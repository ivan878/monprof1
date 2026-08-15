// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/auth/data/models/prepa_user.dart';
import 'package:monprof/prepa/user/controllers/profile_controller.dart';
import 'package:monprof/prepa/user/screens/complete_profile_screen.dart';
import 'package:monprof/prepa/user/screens/profile_screen.dart' show showLogoutDialog;
import 'package:provider/provider.dart';
import 'package:monprof/prepa/user/screens/update_password_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PrepaProfileController>().loadProfile(),
    );
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _version = 'v${info.version}+${info.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrepaProfileController>(
      builder: (context, controller, _) {
        final user = controller.state.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const SimpleText(
              text: 'Settings',
              size: 20,
              weight: FontWeight.bold,
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // ── ACCOUNT ───────────────────────────────────────────────────
              _SectionHeader(text: 'ACCOUNT'),
              _Card(
                children: [
                  // User card
                  _UserTile(
                    user: user,
                    onEdit: () async {
                      final updated = await Navigator.push<PrepaUser>(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: CompleteProfileScreen(user: user),
                        ),
                      );
                      if (updated != null) controller.loadProfile();
                    },
                  ),
                  _Divider(),
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.person_outline_rounded,
                        color: Colors.blue.shade400),
                    title: 'Personal Information',
                    onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: CompleteProfileScreen(user: user),
                      ),
                    ),
                  ),
                  _Divider(),
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.school_outlined,
                        color: Colors.green.shade500),
                    title: 'Exam Preferences',
                    onTap: () {
                      Notify.toast('Fonctionnalité bientôt disponible');
                    },
                  ),
                  _Divider(),
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.notifications_outlined,
                        color: Colors.purple.shade400),
                    title: 'Notifications',
                    onTap: () {
                      Notify.toast('Fonctionnalité bientôt disponible');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── APP SETTINGS ──────────────────────────────────────────────
              _SectionHeader(text: 'APP SETTINGS'),
              _Card(
                children: [
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.language_rounded,
                        color: Colors.blue.shade600),
                    title: 'Language',
                    trailing: SimpleText(
                      text: 'Français',
                      size: 13,
                      color: onGrey300,
                    ),
                    onTap: () {
                      Notify.toast('Fonctionnalité bientôt disponible');
                    },
                  ),
                  _Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        _IconBox(
                            icon: Icons.dark_mode_outlined,
                            color: Colors.blueGrey.shade600),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SimpleText(
                              text: 'Dark Mode', size: 14),
                        ),
                        Switch(
                          value: _darkMode,
                          activeThumbColor: prepaPrimaryColor,
                          activeTrackColor: prepaPrimaryColor.withValues(alpha: 0.4),
                          onChanged: (v) {
                            setState(() => _darkMode = v);
                            Notify.toast(
                                'Mode sombre bientôt disponible');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── SECURITY ─────────────────────────────────────────────────
              _SectionHeader(text: 'SECURITY'),
              _Card(
                children: [
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.lock_outline_rounded,
                        color: Colors.orange.shade600),
                    title: 'Change Password',
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

              const SizedBox(height: 20),

              // ── SUPPORT ──────────────────────────────────────────────────
              _SectionHeader(text: 'SUPPORT'),
              _Card(
                children: [
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.headset_mic_outlined,
                        color: Colors.red.shade400),
                    title: 'Contact Customer Service',
                    trailingIcon: Icons.open_in_new_rounded,
                    onTap: () async {
                      final uri =
                          Uri.parse('mailto:support@mutrix.org');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                  _Divider(),
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.privacy_tip_outlined,
                        color: Colors.green.shade600),
                    title: 'Privacy Policy',
                    onTap: () async {
                      final uri = Uri.parse(
                          'https://mutrix.org/privacy');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  _Divider(),
                  _SettingsRow(
                    icon: _IconBox(
                        icon: Icons.description_outlined,
                        color: Colors.blueGrey.shade500),
                    title: 'Terms of Service',
                    onTap: () async {
                      final uri =
                          Uri.parse('https://mutrix.org/terms');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── FOLLOW US ────────────────────────────────────────────────
              _SectionHeader(text: 'FOLLOW US'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SocialButton(
                      icon: Icons.facebook_rounded,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      url: 'https://facebook.com/mutrix',
                    ),
                    _SocialButton(
                      icon: Icons.alternate_email_rounded,
                      label: 'Twitter',
                      color: const Color(0xFF1DA1F2),
                      url: 'https://twitter.com/mutrix',
                    ),
                    _SocialButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Instagram',
                      color: const Color(0xFFE1306C),
                      url: 'https://instagram.com/mutrix',
                    ),
                    _SocialButton(
                      icon: Icons.work_outline_rounded,
                      label: 'LinkedIn',
                      color: const Color(0xFF0077B5),
                      url: 'https://linkedin.com/company/mutrix',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Déconnexion ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => _showLogoutDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded,
                            color: Colors.red.shade600, size: 20),
                        const SizedBox(width: 10),
                        SimpleText(
                          text: 'Log Out',
                          size: 15,
                          weight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Version ──────────────────────────────────────────────────
              Center(
                child: SimpleText(
                  text: 'Prépas Concours $_version',
                  size: 12,
                  color: Colors.grey.shade400,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // Même parcours que depuis le profil : session fermée + purge locale.
  void _showLogoutDialog(BuildContext context) => showLogoutDialog(context);
}

// ── Widgets utilitaires ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: SimpleText(
        text: text,
        size: 11,
        weight: FontWeight.w700,
        color: onGrey300,
        letterspacing: 0.8,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56, endIndent: 16);
  }
}

class _UserTile extends StatelessWidget {
  final PrepaUser? user;
  final VoidCallback onEdit;

  const _UserTile({this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar initiales
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: prepaPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SimpleText(
                text: user?.name.isNotEmpty == true
                    ? _initials(user!.name)
                    : '?',
                size: 18,
                weight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleText(
                  text: user?.name ?? 'Utilisateur',
                  size: 15,
                  weight: FontWeight.bold,
                ),
                const SizedBox(height: 3),
                SimpleText(
                  text:
                      '${user?.roles.firstOrNull ?? 'Étudiant'} • CPGE Profile',
                  size: 12,
                  color: onGrey300,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              foregroundColor: prepaPrimaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const SimpleText(
              text: 'Edit',
              size: 13,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

class _SettingsRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget? trailing;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: SimpleText(text: title, size: 14),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 4),
            ],
            Icon(
              trailingIcon ?? Icons.arrow_forward_ios_rounded,
              size: 13,
              color: onGrey300,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          SimpleText(text: label, size: 11, color: onGrey300),
        ],
      ),
    );
  }
}
