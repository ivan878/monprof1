import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/prepa/common/apple_review_mode.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/common/widgets/user_avatar.dart';
import 'package:monprof/prepa/home/home_controller.dart';
import 'package:monprof/prepa/home/widgets/home_concours_scroll.dart';
import 'package:monprof/prepa/home/widgets/home_historique_section.dart';
import 'package:monprof/prepa/home/widgets/home_section_header.dart';
import 'package:monprof/prepa/home/widgets/home_vos_concours_section.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  /// Bascule vers l'onglet « Mes Concours ». Fourni par l'écran hôte, qui seul
  /// possède le contrôleur de pages.
  final VoidCallback? onSeeAllConcours;

  const DashboardPage({super.key, this.onSeeAllConcours});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<HomeController>().initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, ctrl, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: _buildAppBar(ctrl),
          body: RefreshIndicator(
            onRefresh: ctrl.refresh,
            color: prepaPrimaryColor,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const SizedBox(height: 12),
                HomeSectionHeader(title: 'Concours en cours'),
                HomeConcoursScroll(ctrl: ctrl),
                const SizedBox(height: 20),
                HomeSectionHeader(
                  title: 'Vos Concours',
                  actionLabel: 'Voir tout',
                  onAction: widget.onSeeAllConcours,
                ),
                // Aperçu limité à 2 — la liste complète est dans l'onglet dédié.
                HomeVosConcoursSection(ctrl: ctrl, limit: 2),

                // Historique de lecture masqué en mode restreint iOS
                if (!AppleReviewMode.instance.isActive) ...[
                  const SizedBox(height: 20),
                  HomeSectionHeader(
                    title: 'Historique des cours',
                    actionLabel: 'Voir tout',
                    onAction: () {},
                  ),
                  HomeHistoriqueSection(ctrl: ctrl),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(HomeController ctrl) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Icon(Icons.school_rounded, color: prepaPrimaryColor, size: 26),
          const SizedBox(width: 8),
          const SimpleText(
            text: 'Prépas Concours',
            size: 18,
            weight: FontWeight.bold,
          ),
          const Spacer(),
          if (ctrl.user == null)
            UserAvatar(user: ctrl.user, size: 36, initialsSize: 13),
        ],
      ),
    );
  }
}
