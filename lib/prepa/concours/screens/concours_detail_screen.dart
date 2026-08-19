// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/apple_review_mode.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/controllers/concours_detail_controller.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/models/matiere_session_model.dart';
import 'package:monprof/prepa/concours/data/models/session_model.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';
import 'package:monprof/prepa/cours/data/models/matiere_model.dart';
import 'package:monprof/prepa/cours/screens/matiere_detail_screen.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';
import 'package:monprof/prepa/subscription/screens/activation_screen.dart';
import 'package:monprof/prepa/subscription/screens/payment_screen.dart';
import 'package:page_transition/page_transition.dart';

class ConcoursDetailScreen extends StatefulWidget {
  final String concoursId;

  const ConcoursDetailScreen({super.key, required this.concoursId});

  @override
  State<ConcoursDetailScreen> createState() => _ConcoursDetailScreenState();
}

class _ConcoursDetailScreenState extends State<ConcoursDetailScreen> {
  late final ConcoursDetailController _ctrl;
  late final SubscriptionRepository _subRepo;

  bool _loadingPayment = false;

  // Subscription check
  SubscriptionModel? _mySubscription;
  bool _subLoading = false;
  bool _subChecked = false;

  @override
  void initState() {
    super.initState();
    _ctrl = ConcoursDetailController(
      repository: GetIt.instance<ConcoursRepository>(),
      concoursId: widget.concoursId,
    );
    _subRepo = GetIt.instance<SubscriptionRepository>();
    _ctrl.addListener(_onConcoursStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.load());
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onConcoursStateChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onConcoursStateChanged() {
    final session = _ctrl.state.data?.activeSession;
    if (_ctrl.state.hasData &&
        session != null &&
        !_subChecked &&
        !_subLoading) {
      _checkSubscription(session.id);
    }
  }

  Future<void> _checkSubscription(String sessionId) async {
    setState(() => _subLoading = true);
    final result = await _subRepo.getMySubscriptionBySession(sessionId);
    if (!mounted) return;
    setState(() {
      _subLoading = false;
      _subChecked = true;
      _mySubscription = result.hasData ? result.data : null;
    });
  }

  /// Après une activation par code (ou un paiement) : le concours et l'état de
  /// souscription ont changé côté serveur, la vue doit repartir des données
  /// fraîches plutôt que de l'ancien état local.
  Future<void> _refreshAfterAccessChange() async {
    if (!mounted) return;
    setState(() {
      _subChecked = false;
      _mySubscription = null;
    });

    await _ctrl.load();
    if (!mounted) return;

    // `_ctrl.load()` notifie ses écouteurs, ce qui relance normalement la
    // vérification ; ce filet couvre le cas où elle n'a pas été déclenchée.
    final session = _ctrl.state.data?.activeSession;
    if (session != null && !_subChecked && !_subLoading) {
      await _checkSubscription(session.id);
    }
  }

  Future<void> _goToPayment(ConcoursModel concours) async {
    if (_loadingPayment) return;

    if (concours.activeSession != null) {
      await Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PaymentScreen(concours: concours),
        ),
      );
      // Le paiement a pu aboutir pendant la navigation : on repart du serveur.
      await _refreshAfterAccessChange();
      return;
    }

    setState(() => _loadingPayment = true);
    final result = await _ctrl.repository.getConcoursById(concours.id);
    setState(() => _loadingPayment = false);

    if (!mounted) return;

    if (result.hasData && result.data?.activeSession != null) {
      await Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: PaymentScreen(concours: result.data!),
        ),
      );
      await _refreshAfterAccessChange();
    } else {
      Notify.toast('Aucune session active pour ce concours');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        if (_ctrl.state.isLoading || _ctrl.state.data == null) {
          return const Scaffold(body: Loading());
        }

        if (_ctrl.state.hasError) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
            body: ErrorPage(
              errorMessage:
                  _ctrl.state.errorModel?.error ?? 'Erreur de chargement',
              reload: _ctrl.load,
            ),
          );
        }

        final concours = _ctrl.state.data!;
        final session = concours.activeSession;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: CustomScrollView(
            slivers: [
              _buildBanner(context, concours, session),
              if (session != null)
                SliverToBoxAdapter(child: _DatesTile(session: session)),
              if (concours.description != null)
                SliverToBoxAdapter(
                  child: _DescriptionCard(description: concours.description!),
                ),
              if (session != null && session.matieres.isNotEmpty)
                SliverToBoxAdapter(
                  child: _MatieresCard(session: session, concours: concours),
                ),
              SliverToBoxAdapter(
                child: _buildActionSection(concours, session),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionSection(ConcoursModel concours, SessionModel? session) {
    // Still loading subscription status
    if (_subLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: SizedBox(
          height: 52,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final subStatus = _mySubscription?.status?.toUpperCase();

    // Active subscription → hide buy buttons
    if (subStatus == 'RUNNING') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.green.shade600, size: 18),
              const SizedBox(width: 8),
              SimpleText(
                text: 'Vous êtes inscrit à ce concours',
                size: 14,
                weight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ],
          ),
        ),
      );
    }

    // Payment in progress
    if (subStatus == 'PENDING' || subStatus == 'INITIATE') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.orange),
                ),
              ),
              const SizedBox(width: 10),
              SimpleText(
                text: 'Paiement en cours de confirmation…',
                size: 14,
                weight: FontWeight.w500,
                color: Colors.orange.shade700,
              ),
            ],
          ),
        ),
      );
    }

    // No subscription (or CANCELED) → subscribe + activate buttons
    final price = session?.amount != null
        ? '${session!.amount!.toStringAsFixed(0)} FCFA'
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: _loadingPayment ? null : () => _goToPayment(concours),
              style: ElevatedButton.styleFrom(
                backgroundColor: prepaPrimaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    prepaPrimaryColor.withValues(alpha: 0.6),
                minimumSize: const Size(double.infinity, 52),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _loadingPayment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : SimpleText(
                      // En mode restreint iOS, aucun tarif n'est affiché
                      text: AppleReviewMode.instance.isActive
                          ? 'Acheter une place'
                          : (price.isNotEmpty
                              ? 'Souscrire — $price'
                              : 'Souscrire'),
                      size: 14,
                      weight: FontWeight.bold,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () async {
                final activated = await Navigator.push<bool>(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    // La session est transmise : un code acheté pour un autre
                    // concours est refusé sans être consommé.
                    child: ActivationScreen(
                      concoursSessionId: session?.id,
                      concoursName: concours.name,
                    ),
                  ),
                );
                if (activated == true) await _refreshAfterAccessChange();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: prepaPrimaryColor,
                side: const BorderSide(color: prepaPrimaryColor),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const SimpleText(
                text: 'Activer',
                size: 14,
                weight: FontWeight.bold,
                color: prepaPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildBanner(
    BuildContext context,
    ConcoursModel concours,
    SessionModel? session,
  ) {
    final statusLabel = session?.status?.toUpperCase() ?? '';
    final statusColor = _sessionStatusColor(session?.status);

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: prepaPrimaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            concours.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: concours.logoUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.4),
                    colorBlendMode: BlendMode.darken,
                    placeholder: (_, __) => _bannerPlaceholder(),
                    errorWidget: (_, __, ___) => _bannerPlaceholder(),
                  )
                : _bannerPlaceholder(),
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (statusLabel.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SimpleText(
                        text: statusLabel,
                        size: 11,
                        weight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  SimpleText(
                    text: concours.name ?? '',
                    size: 22,
                    weight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      color: prepaPrimaryColor,
      child: const Center(
        child: Icon(Icons.school_rounded, size: 80, color: Colors.white38),
      ),
    );
  }

  Color _sessionStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ONGOING':
        return Colors.green.shade600;
      case 'COMPLETED':
        return Colors.grey.shade600;
      case 'UPCOMING':
        return Colors.blue.shade600;
      case 'CANCELED':
        return Colors.red.shade600;
      default:
        return Colors.blueGrey.shade600;
    }
  }
}

// ── Dates ─────────────────────────────────────────────────────────────────────

class _DatesTile extends StatelessWidget {
  final SessionModel session;
  const _DatesTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr');
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          _DateChip(
            icon: Icons.calendar_today_rounded,
            label: 'Début',
            value: session.startDate != null
                ? fmt.format(session.startDate!)
                : '--',
          ),
          Expanded(
            child: Center(
              child: Container(height: 1, color: Colors.grey.shade200),
            ),
          ),
          _DateChip(
            icon: Icons.event_rounded,
            label: 'Fin',
            value:
                session.endDate != null ? fmt.format(session.endDate!) : '--',
            alignRight: true,
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool alignRight;

  const _DateChip({
    required this.icon,
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      Icon(icon, size: 18, color: prepaPrimaryColor),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SimpleText(text: label, size: 11, color: onGrey300),
          SimpleText(text: value, size: 13, weight: FontWeight.bold),
        ],
      ),
    ];
    return Row(children: alignRight ? children.reversed.toList() : children);
  }
}

// ── Description ───────────────────────────────────────────────────────────────

class _DescriptionCard extends StatelessWidget {
  final String description;
  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SimpleText(
            text: 'À PROPOS DU CONCOURS',
            size: 12,
            weight: FontWeight.bold,
            color: onGrey300,
          ),
          const SizedBox(height: 10),
          SimpleText(text: description, size: 14, color: darkColorSecond),
        ],
      ),
    );
  }
}

// ── Matières au programme ─────────────────────────────────────────────────────

class _MatieresCard extends StatelessWidget {
  final SessionModel session;
  final ConcoursModel concours;
  const _MatieresCard({required this.session, required this.concours});

  @override
  Widget build(BuildContext context) {
    final count = session.matieres.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SimpleText(
            text:
                'MATIÈRES AU PROGRAMME — $count Épreuve${count > 1 ? 's' : ''}',
            size: 12,
            weight: FontWeight.bold,
            color: onGrey300,
          ),
          const SizedBox(height: 12),
          ...session.matieres.map(
            (m) => _MatiereTile(matiere: m, concours: concours),
          ),
        ],
      ),
    );
  }
}

class _MatiereTile extends StatelessWidget {
  final MatiereSessionModel matiere;
  final ConcoursModel concours;
  const _MatiereTile({required this.matiere, required this.concours});

  @override
  Widget build(BuildContext context) {
    final dureeH = matiere.dureeMinutes != null
        ? '${(matiere.dureeMinutes! / 60).toStringAsFixed(0)}h'
        : null;
    final coeff = matiere.coefficient != null
        ? 'Coeff. ${matiere.coefficient!.toStringAsFixed(0)}'
        : null;

    // Mode restreint iOS : le détail d'une matière donne accès aux vidéos,
    // la navigation est donc neutralisée.
    final locked = AppleReviewMode.instance.isActive;

    return GestureDetector(
      onTap: locked
          ? null
          : () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: MatiereDetailScreen(
                    matiere: MatiereModel(
                      id: matiere.id,
                      name: matiere.name,
                      logoUrl: matiere.logoUrl,
                    ),
                    concours: concours,
                  ),
                ),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: prepaPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: matiere.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: matiere.logoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.menu_book_rounded,
                          color: prepaPrimaryColor,
                          size: 20,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.menu_book_rounded,
                      color: prepaPrimaryColor,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(
                    text: matiere.name ?? 'Matière',
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                  if (dureeH != null || coeff != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (dureeH != null)
                          SimpleText(
                              text: dureeH, size: 12, weight: FontWeight.bold),
                        if (dureeH != null && coeff != null)
                          SimpleText(text: '  ·  ', size: 12, color: onGrey300),
                        if (coeff != null)
                          SimpleText(text: coeff, size: 12, color: onGrey300),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Sans navigation possible, le chevron induirait en erreur
            if (!locked) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 13, color: onGrey300),
            ],
          ],
        ),
      ),
    );
  }
}

List<BoxShadow> _cardShadow() {
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];
}
