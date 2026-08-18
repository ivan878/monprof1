import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/home/home_controller.dart';
import 'package:monprof/prepa/home/widgets/home_vos_concours_section.dart';
import 'package:provider/provider.dart';

/// Onglet « Mes Concours » : les concours auxquels l'utilisateur a souscrit.
///
/// Même source et même rendu que la section « Vos Concours » du tableau de
/// bord — celle-ci en montre 2, cet écran les affiche tous.
class ConcoursListScreen extends StatefulWidget {
  const ConcoursListScreen({super.key});

  @override
  State<ConcoursListScreen> createState() => _ConcoursListScreenState();
}

class _ConcoursListScreenState extends State<ConcoursListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<HomeController>();
      // Le tableau de bord a pu déjà charger : on ne refait l'appel que si besoin.
      if (ctrl.subscriptionsState.data == null) ctrl.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, ctrl, _) {
        final count = HomeVosConcoursSection.activeSubscriptions(ctrl).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: const SimpleText(
              text: 'Mes Concours',
              size: 20,
              weight: FontWeight.bold,
            ),
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: _buildBody(ctrl, count),
        );
      },
    );
  }

  Widget _buildBody(HomeController ctrl, int count) {
    final subsState = ctrl.subscriptionsState;

    if (subsState.isLoading && subsState.data == null) {
      return const Loading();
    }

    if (subsState.hasError && subsState.data == null) {
      return ErrorPage(
        errorMessage: subsState.errorModel?.error ?? 'Erreur de chargement',
        reload: ctrl.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.refresh,
      color: prepaPrimaryColor,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        children: [
          if (count > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SimpleText(
                text: '$count concours suivi${count > 1 ? 's' : ''}',
                size: 13,
                color: onGrey300,
              ),
            ),
          // Sans `limit` : la liste complète, avec le même rendu qu'à l'accueil.
          HomeVosConcoursSection(ctrl: ctrl),
        ],
      ),
    );
  }
}
