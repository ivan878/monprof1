import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/screens/concours_detail_screen.dart';
import 'package:monprof/prepa/home/home_controller.dart';
import 'package:monprof/prepa/home/widgets/home_empty_state.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:page_transition/page_transition.dart';

class HomeVosConcoursSection extends StatelessWidget {
  final HomeController ctrl;

  /// Nombre maximum d'éléments affichés. `null` = tous.
  /// Le tableau de bord en montre 2 et renvoie vers l'onglet dédié pour le reste.
  final int? limit;

  const HomeVosConcoursSection({super.key, required this.ctrl, this.limit});

  /// Souscriptions exploitables — partagées entre le tableau de bord et
  /// l'onglet « Mes Concours » pour garantir une liste identique.
  static List<SubscriptionModel> activeSubscriptions(HomeController ctrl) {
    return (ctrl.subscriptionsState.data ?? []).where((s) {
      final st = s.status?.toUpperCase();
      return st == 'RUNNING' || st == 'PENDING' || st == 'INITIATE';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (ctrl.subscriptionsState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final all = activeSubscriptions(ctrl);
    final actives = limit != null ? all.take(limit!).toList() : all;

    if (actives.isEmpty) {
      return const HomeEmptyState(
        icon: Icons.assignment_outlined,
        title: 'Pas encore d\'inscription',
        subtitle: 'Vos concours actifs apparaîtront ici',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: actives
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _VosConcoursTile(sub: s),
                ))
            .toList(),
      ),
    );
  }
}

class _VosConcoursTile extends StatelessWidget {
  final SubscriptionModel sub;
  const _VosConcoursTile({required this.sub});

  @override
  Widget build(BuildContext context) {
    final endDate = sub.sessionEndDate;
    final daysLeft = endDate?.difference(DateTime.now()).inDays;
    final isExpired = daysLeft != null && daysLeft < 0;
    final isRunning = sub.status?.toUpperCase() == 'RUNNING';

    final dayLabel =
        daysLeft != null ? (isExpired ? 'Terminé' : 'J-$daysLeft') : null;
    final dayColor = isExpired ? Colors.red.shade400 : prepaPrimaryColor;

    return GestureDetector(
      onTap: sub.concoursId != null
          ? () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ConcoursDetailScreen(concoursId: sub.concoursId!),
                ),
              )
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: sub.concoursLogoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: sub.concoursLogoUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            memCacheWidth: 88,
                            memCacheHeight: 88,
                            errorWidget: (_, __, ___) => _logoPlaceholder(),
                          )
                        : _logoPlaceholder(),
                  ),
                  const SizedBox(width: 12),

                  // Name + session + badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SimpleText(
                          text: sub.concoursName ?? 'Concours',
                          size: 14,
                          weight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _StatusBadge(
                                isRunning: isRunning, status: sub.status),
                            if (dayLabel != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: dayColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: SimpleText(
                                  text: dayLabel,
                                  size: 11,
                                  weight: FontWeight.bold,
                                  color: dayColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  Icon(Icons.chevron_right_rounded, size: 18, color: onGrey300),
                ],
              ),
            ),

            // Progress bar at bottom
            if (sub.sessionStartDate != null && sub.sessionEndDate != null)
              LinearProgressIndicator(
                value: _progressValue(),
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isExpired ? Colors.grey.shade300 : prepaPrimaryColor,
                ),
                minHeight: 3,
              ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: prepaPrimaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          const Icon(Icons.school_rounded, color: prepaPrimaryColor, size: 22),
    );
  }

  double _progressValue() {
    final start = sub.sessionStartDate;
    final end = sub.sessionEndDate;
    if (start == null || end == null) return 0;
    final total = end.difference(start).inDays;
    if (total <= 0) return 1;
    return (DateTime.now().difference(start).inDays / total).clamp(0.0, 1.0);
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isRunning;
  final String? status;
  const _StatusBadge({required this.isRunning, this.status});

  @override
  Widget build(BuildContext context) {
    final Color dot;
    final Color bg;
    final String label;

    switch (status?.toUpperCase()) {
      case 'RUNNING':
        dot = Colors.green.shade600;
        bg = Colors.green.shade50;
        label = 'Actif';
        break;
      case 'PENDING':
        dot = Colors.orange.shade600;
        bg = Colors.orange.shade50;
        label = 'En attente';
        break;
      case 'INITIATE':
        dot = Colors.blue.shade600;
        bg = Colors.blue.shade50;
        label = 'Initié';
        break;
      default:
        dot = Colors.grey.shade400;
        bg = Colors.grey.shade100;
        label = status ?? 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          SimpleText(
            text: label,
            size: 10,
            weight: FontWeight.w600,
            color: dot,
          ),
        ],
      ),
    );
  }
}
