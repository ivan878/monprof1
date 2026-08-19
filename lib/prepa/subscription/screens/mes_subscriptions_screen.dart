import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/subscription/controllers/mes_subscriptions_controller.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

// ── Présentation des statuts ─────────────────────────────────────────────────

({Color color, String label}) _statusOf(String? status) {
  switch (status?.toUpperCase()) {
    case 'RUNNING':
      return (color: Colors.green.shade600, label: 'Active');
    case 'PENDING':
      return (color: Colors.orange.shade700, label: 'En attente');
    case 'INITIATE':
      return (color: Colors.blue.shade600, label: 'Initiée');
    case 'CODES_ISSUED':
      return (color: prepaPrimaryColor, label: 'Codes émis');
    case 'PAYMENT_FAILED':
      return (color: Colors.red.shade700, label: 'Paiement échoué');
    case 'CANCELED':
    case 'CANCELLED':
      return (color: Colors.grey.shade500, label: 'Annulée');
    case 'TERMINATED':
      return (color: Colors.grey.shade600, label: 'Terminée');
    case 'INACTIVE':
      return (color: Colors.grey.shade500, label: 'Inactive');
    default:
      return (color: Colors.grey.shade500, label: status ?? 'Inconnu');
  }
}

final _dateFmt = DateFormat('dd/MM/yyyy');
final _dateTimeFmt = DateFormat('dd/MM/yyyy à HH:mm');

String _fmtAmount(double? v) =>
    v == null ? '—' : '${NumberFormat.decimalPattern('fr').format(v)} FCFA';

// ── Écran ────────────────────────────────────────────────────────────────────

class MesSubscriptionsScreen extends StatefulWidget {
  const MesSubscriptionsScreen({super.key});

  @override
  State<MesSubscriptionsScreen> createState() => _MesSubscriptionsScreenState();
}

class _MesSubscriptionsScreenState extends State<MesSubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// Clé du Scaffold : le drawer de détail est ouvert par programme.
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SubscriptionModel? _selected;

  final List<_TabDef> _tabs = const [
    _TabDef(label: 'Toutes', status: null),
    _TabDef(label: 'Actives', status: 'RUNNING'),
    _TabDef(label: 'En attente', status: 'PENDING'),
    _TabDef(label: 'Codes émis', status: 'CODES_ISSUED'),
    _TabDef(label: 'Annulées', status: 'CANCELED'),
    _TabDef(label: 'Terminées', status: 'TERMINATED'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDetail(SubscriptionModel sub) {
    setState(() => _selected = sub);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      // Panneau latéral droit — équivalent du drawer de la console
      endDrawer: _SubscriptionDetailDrawer(subscription: _selected),
      appBar: AppBar(
        title: const SimpleText(
          text: 'Mes Inscriptions',
          size: 20,
          weight: FontWeight.bold,
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: prepaPrimaryColor,
          unselectedLabelColor: onGrey300,
          indicatorColor: prepaPrimaryColor,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((t) => _SubscriptionList(
                  statusFilter: t.status,
                  onOpenDetail: _openDetail,
                ))
            .toList(),
      ),
    );
  }
}

class _TabDef {
  final String label;
  final String? status;
  const _TabDef({required this.label, this.status});
}

// ── Liste par onglet ─────────────────────────────────────────────────────────

class _SubscriptionList extends StatefulWidget {
  final String? statusFilter;
  final ValueChanged<SubscriptionModel> onOpenDetail;

  const _SubscriptionList({this.statusFilter, required this.onOpenDetail});

  @override
  State<_SubscriptionList> createState() => _SubscriptionListState();
}

class _SubscriptionListState extends State<_SubscriptionList>
    with AutomaticKeepAliveClientMixin {
  late final MesSubscriptionsController _ctrl;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ctrl = MesSubscriptionsController(
      repository: GetIt.instance<SubscriptionRepository>(),
      statusFilter: widget.statusFilter,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.loadSubscriptions());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        if (_ctrl.state.isLoading && _ctrl.items.isEmpty) return const Loading();

        if (_ctrl.state.hasError && _ctrl.items.isEmpty) {
          return ErrorPage(
            errorMessage:
                _ctrl.state.errorModel?.error ?? 'Erreur de chargement',
            reload: _ctrl.loadSubscriptions,
          );
        }

        if (_ctrl.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                SimpleText(
                  text: 'Aucune inscription',
                  size: 15,
                  color: onGrey300,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _ctrl.refresh,
          color: prepaPrimaryColor,
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 300 &&
                  !_ctrl.state.isLoading &&
                  _ctrl.hasMore) {
                _ctrl.loadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ctrl.items.length + (_ctrl.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _ctrl.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final sub = _ctrl.items[index];
                return _SubscriptionCard(
                  sub: sub,
                  onTap: () => widget.onOpenDetail(sub),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Carte ────────────────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionModel sub;
  final VoidCallback onTap;

  const _SubscriptionCard({required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final st = _statusOf(sub.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _ConcoursLogo(url: sub.concoursLogoUrl, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleText(
                      text: sub.concoursName ?? 'Concours',
                      size: 14,
                      weight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      maxlines: 2,
                    ),
                    if (sub.sessionName != null) ...[
                      const SizedBox(height: 2),
                      SimpleText(
                        text: sub.sessionName!,
                        size: 12,
                        color: onGrey300,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Pill(label: st.label, color: st.color, dot: true),
                        _Pill(
                          label: sub.isGroupPurchase
                              ? '${sub.count} places'
                              : '1 place',
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 20, color: onGrey300),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcoursLogo extends StatelessWidget {
  final String? url;
  final double size;
  const _ConcoursLogo({this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: prepaPrimaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.school_rounded,
          color: prepaPrimaryColor, size: size * 0.5),
    );

    if (url == null) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: (size * 2).round(),
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;

  const _Pill({required this.label, required this.color, this.dot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          SimpleText(
            text: label,
            size: 11,
            weight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── Drawer de détail (sort par la droite) ────────────────────────────────────

class _SubscriptionDetailDrawer extends StatelessWidget {
  final SubscriptionModel? subscription;

  const _SubscriptionDetailDrawer({this.subscription});

  @override
  Widget build(BuildContext context) {
    final sub = subscription;
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      width: width * 0.92,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: sub == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Divider(height: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                      children: [
                        _HeroBlock(sub: sub),
                        const SizedBox(height: 22),
                        _Section(title: 'Concours', rows: [
                          ('Concours', sub.concoursName ?? '—'),
                          ('Session', sub.sessionName ?? '—'),
                          ('Période', _period(sub)),
                          ('Statut session', sub.sessionStatus ?? '—'),
                          ('Prix unitaire', _fmtAmount(sub.sessionAmount)),
                          ('Total estimé', _fmtAmount(sub.totalAmount)),
                        ]),
                        const SizedBox(height: 20),
                        _Section(title: 'Souscription', rows: [
                          ('Places', '${sub.count ?? 1}'),
                          (
                            'Type',
                            sub.isGroupPurchase
                                ? 'Achat groupé (codes)'
                                : 'Achat individuel'
                          ),
                          ('Souscrit le', sub.createdAt == null
                              ? '—'
                              : _dateTimeFmt.format(sub.createdAt!)),
                          ('Mise à jour', sub.updatedAt == null
                              ? '—'
                              : _dateTimeFmt.format(sub.updatedAt!)),
                        ], statusRow: sub.status),
                        if (sub.isGroupPurchase) ...[
                          const SizedBox(height: 18),
                          _InfoNote(
                            icon: Icons.confirmation_number_outlined,
                            text: 'Cet achat a généré ${sub.count} codes '
                                'd\'activation. Retrouvez-les dans « Mes codes ».',
                          ),
                        ],
                        if (sub.isRunning && sub.daysLeft != null) ...[
                          const SizedBox(height: 18),
                          _RemainingBar(sub: sub),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleText(
                  text: 'SOUSCRIPTION',
                  size: 11,
                  weight: FontWeight.bold,
                  letterspacing: 1,
                  color: prepaPrimaryColor,
                ),
                const SizedBox(height: 3),
                const SimpleText(
                  text: 'Détail de la souscription',
                  size: 18,
                  weight: FontWeight.bold,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _period(SubscriptionModel sub) {
    if (sub.sessionStartDate == null && sub.sessionEndDate == null) return '—';
    final a = sub.sessionStartDate == null
        ? '—'
        : _dateFmt.format(sub.sessionStartDate!);
    final b =
        sub.sessionEndDate == null ? '—' : _dateFmt.format(sub.sessionEndDate!);
    return '$a → $b';
  }
}

/// Bandeau de tête : concours, session, statut et nombre de places.
class _HeroBlock extends StatelessWidget {
  final SubscriptionModel sub;
  const _HeroBlock({required this.sub});

  @override
  Widget build(BuildContext context) {
    final st = _statusOf(sub.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConcoursLogo(url: sub.concoursLogoUrl, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleText(
                      text: 'CONCOURS',
                      size: 10,
                      weight: FontWeight.bold,
                      letterspacing: 0.8,
                      color: onGrey300,
                    ),
                    const SizedBox(height: 4),
                    SimpleText(
                      text: sub.concoursName ?? 'Concours',
                      size: 16,
                      weight: FontWeight.bold,
                      maxlines: 3,
                    ),
                    if (sub.sessionName != null) ...[
                      const SizedBox(height: 3),
                      SimpleText(
                        text: sub.sessionName!,
                        size: 12.5,
                        color: onGrey300,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Pill(label: st.label, color: st.color, dot: true),
              const SizedBox(width: 6),
              _Pill(
                label: sub.isGroupPurchase ? '${sub.count} places' : '1 place',
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bloc « clé / valeur » aligné, à l'image des sections du panneau admin.
class _Section extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;

  /// Rendu en badge plutôt qu'en texte lorsqu'il est fourni.
  final String? statusRow;

  const _Section({required this.title, required this.rows, this.statusRow});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleText(
          text: title.toUpperCase(),
          size: 11,
          weight: FontWeight.bold,
          letterspacing: 0.8,
          color: onGrey300,
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: Colors.grey.shade200),
        const SizedBox(height: 10),
        if (statusRow != null) _statusLine(statusRow!),
        ...rows.map((r) => _line(r.$1, r.$2)),
      ],
    );
  }

  Widget _statusLine(String status) {
    final st = _statusOf(status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: SimpleText(text: 'Statut', size: 13, color: onGrey300),
          ),
          _Pill(label: st.label, color: st.color, dot: true),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: SimpleText(text: label, size: 13, color: onGrey300),
          ),
          Expanded(
            child: SimpleText(
              text: value,
              size: 13,
              weight: FontWeight.w500,
              maxlines: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: prepaPrimaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: prepaPrimaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: prepaPrimaryColor),
          const SizedBox(width: 9),
          Expanded(
            child: SimpleText(text: text, size: 12.5, color: onGrey300),
          ),
        ],
      ),
    );
  }
}

/// Progression de la session pour une souscription active.
class _RemainingBar extends StatelessWidget {
  final SubscriptionModel sub;
  const _RemainingBar({required this.sub});

  @override
  Widget build(BuildContext context) {
    final days = sub.daysLeft!;
    final expired = days < 0;
    final start = sub.sessionStartDate;
    final end = sub.sessionEndDate;

    double progress = 0;
    if (start != null && end != null) {
      final total = end.difference(start).inDays;
      progress = total <= 0
          ? 1
          : (DateTime.now().difference(start).inDays / total).clamp(0.0, 1.0);
    }

    final color = expired ? Colors.grey.shade400 : Colors.green.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 15, color: color),
            const SizedBox(width: 6),
            SimpleText(
              text: expired
                  ? 'Session terminée'
                  : 'Il reste $days jour${days > 1 ? 's' : ''}',
              size: 13,
              weight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
