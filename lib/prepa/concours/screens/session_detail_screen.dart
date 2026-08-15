// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/concours/controllers/session_detail_controller.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';
import 'package:monprof/prepa/subscription/screens/create_subscription_screen.dart';
import 'package:page_transition/page_transition.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late final SessionDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SessionDetailController(
      repository: GetIt.instance<ConcoursRepository>(),
      sessionId: widget.sessionId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.load());
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
        if (_ctrl.state.isLoading) {
          return const Scaffold(body: Loading());
        }

        if (_ctrl.state.hasError || _ctrl.state.data == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
            body: ErrorPage(
              errorMessage:
                  _ctrl.state.errorModel?.error ?? 'Erreur de chargement',
              reload: _ctrl.load,
            ),
          );
        }

        final session = _ctrl.state.data!;

        return Scaffold(
          backgroundColor: grey300,
          appBar: AppBar(
            title: SimpleText(
              text: session.name ?? 'Session',
              size: 18,
              weight: FontWeight.bold,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: _ctrl.refresh,
            color: primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (session.concoursName != null)
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.school_rounded,
                        label: 'Concours',
                        value: session.concoursName!,
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Statut',
                      value: session.status ?? 'N/A',
                      valueColor: _statusColor(session.status),
                    ),
                    if (session.startDate != null)
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Début',
                        value: DateFormat('dd MMMM yyyy', 'fr_FR')
                            .format(session.startDate!),
                      ),
                    if (session.endDate != null)
                      _InfoRow(
                        icon: Icons.calendar_month_rounded,
                        label: 'Fin',
                        value: DateFormat('dd MMMM yyyy', 'fr_FR')
                            .format(session.endDate!),
                      ),
                    if (session.amount != null)
                      _InfoRow(
                        icon: Icons.payment_rounded,
                        label: 'Montant',
                        value:
                            '${session.amount!.toStringAsFixed(0)} FCFA',
                        valueColor: primaryColor,
                        bold: true,
                      ),
                  ],
                ),

                if (session.description != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SimpleText(
                          text: 'Description',
                          size: 15,
                          weight: FontWeight.bold,
                        ),
                        const SizedBox(height: 8),
                        SimpleText(
                          text: session.description!,
                          size: 14,
                          color: darkColorSecond,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                DefaultButton(
                  text: "S'inscrire à cette session",
                  onPressed: session.isActive == true
                      ? () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: CreateSubscriptionScreen(
                                  session: session),
                            ),
                          );
                        }
                      : null,
                  backgroundColor: session.isActive == true
                      ? primaryColor
                      : Colors.grey.shade400,
                ),

                if (session.isActive != true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: SimpleText(
                        text: 'Cette session n\'est plus disponible',
                        size: 12,
                        color: Colors.grey,
                        align: TextAlign.center,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'actif':
        return Colors.green.shade700;
      case 'closed':
      case 'fermé':
        return Colors.red.shade700;
      case 'pending':
      case 'en attente':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}

// ── Widgets utilitaires ──────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children
            .expand((w) => [w, const Divider(height: 20)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 10),
        SimpleText(text: label, size: 14, color: onGrey300),
        const Spacer(),
        SimpleText(
          text: value,
          size: 14,
          weight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor,
        ),
      ],
    );
  }
}
