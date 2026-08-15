// ignore_for_file: use_build_context_synchronously

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

class MesSubscriptionsScreen extends StatefulWidget {
  const MesSubscriptionsScreen({super.key});

  @override
  State<MesSubscriptionsScreen> createState() => _MesSubscriptionsScreenState();
}

class _MesSubscriptionsScreenState extends State<MesSubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  // length updated to match _tabs list (5 entries)

  final List<_TabDef> _tabs = const [
    _TabDef(label: 'Toutes', status: null),
    _TabDef(label: 'Actives', status: 'RUNNING'),
    _TabDef(label: 'En attente', status: 'PENDING'),
    _TabDef(label: 'Annulées', status: 'CANCELED'),
    _TabDef(label: 'Terminées', status: 'TERMINATED'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          labelColor: prepaPrimaryColor,
          unselectedLabelColor: onGrey300,
          indicatorColor: prepaPrimaryColor,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((t) => _SubscriptionList(statusFilter: t.status))
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

// ── Liste par onglet — contrôleur propre à chaque tab ─────────────────────────

class _SubscriptionList extends StatefulWidget {
  final String? statusFilter;

  const _SubscriptionList({this.statusFilter});

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ctrl.loadSubscriptions(),
    );
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
        if (_ctrl.state.isLoading && _ctrl.items.isEmpty) {
          return const Loading();
        }

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
                Icon(Icons.inbox_outlined, size: 64, color: onGrey300),
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
                return _SubscriptionCard(sub: _ctrl.items[index]);
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Carte abonnement ─────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionModel sub;

  const _SubscriptionCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final statusColor = _statusColor(sub.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleText(
                      text: 'Inscription #${sub.id.substring(0, 8)}',
                      size: 13,
                      weight: FontWeight.w600,
                    ),
                    if (sub.concoursSessionId != null)
                      SimpleText(
                        text:
                            'Session: ${sub.concoursSessionId!.substring(0, 8)}...',
                        size: 11,
                        color: onGrey300,
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SimpleText(
                  text: sub.status ?? 'N/A',
                  size: 11,
                  weight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (sub.createdAt != null) ...[
            const Divider(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 13, color: onGrey300),
                const SizedBox(width: 6),
                SimpleText(
                  text: 'Inscrit le ${fmt.format(sub.createdAt!)}',
                  size: 12,
                  color: onGrey300,
                ),
                const Spacer(),
                if (sub.count != null)
                  SimpleText(
                    text: '× ${sub.count}',
                    size: 12,
                    color: onGrey300,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'RUNNING':
        return Colors.green.shade700;
      case 'TERMINATED':
        return Colors.red.shade700;
      case 'PENDING':
        return Colors.orange.shade700;
      case 'INITIATE':
        return Colors.blue.shade600;
      case 'CANCELED':
      case 'CANCELLED':
        return Colors.grey.shade600;
      default:
        return prepaPrimaryColor;
    }
  }
}
