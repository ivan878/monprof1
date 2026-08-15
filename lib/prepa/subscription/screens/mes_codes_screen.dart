import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:monprof/corps/utils/notify.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/subscription/controllers/mes_codes_controller.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_code_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class MesCodesScreen extends StatefulWidget {
  const MesCodesScreen({super.key});

  @override
  State<MesCodesScreen> createState() => _MesCodesScreenState();
}

class _MesCodesScreenState extends State<MesCodesScreen> {
  late final MesCodesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = MesCodesController(
      repository: GetIt.instance<SubscriptionRepository>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.loadCodes());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const SimpleText(
          text: 'Mes codes',
          size: 17,
          weight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_ctrl.state.isLoading && _ctrl.groups.isEmpty) {
      return const Loading();
    }

    if (_ctrl.state.hasError && _ctrl.groups.isEmpty) {
      return ErrorPage(
        errorMessage: _ctrl.state.errorModel?.error ?? 'Erreur de chargement',
        reload: _ctrl.loadCodes,
      );
    }

    if (_ctrl.groups.isEmpty) return const _EmptyCodes();

    return RefreshIndicator(
      onRefresh: _ctrl.refresh,
      color: prepaPrimaryColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SummaryBanner(
            total: _ctrl.totalCodes,
            available: _ctrl.totalAvailable,
          ),
          const SizedBox(height: 14),
          ..._ctrl.groups.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CodeGroupCard(group: g),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bandeau récapitulatif ────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final int total;
  final int available;
  const _SummaryBanner({required this.total, required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: prepaPrimaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: prepaPrimaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              color: prepaPrimaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleText(
                  text: '$available code${available > 1 ? 's' : ''} disponible'
                      '${available > 1 ? 's' : ''}',
                  size: 14,
                  weight: FontWeight.bold,
                  color: prepaPrimaryColor,
                ),
                const SizedBox(height: 2),
                SimpleText(
                  text: 'sur $total acheté${total > 1 ? 's' : ''} • '
                      'partagez-les pour donner accès',
                  size: 12,
                  color: onGrey300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Groupe (un concours / une session) ───────────────────────────────────────

class _CodeGroupCard extends StatefulWidget {
  final SubscriptionCodeGroupModel group;
  const _CodeGroupCard({required this.group});

  @override
  State<_CodeGroupCard> createState() => _CodeGroupCardState();
}

class _CodeGroupCardState extends State<_CodeGroupCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final g = widget.group;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // En-tête cliquable
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: g.concoursLogoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: g.concoursLogoUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            memCacheWidth: 88,
                            errorWidget: (_, __, ___) => _logoPlaceholder(),
                          )
                        : _logoPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SimpleText(
                          text: g.concoursName ?? 'Concours',
                          size: 14,
                          weight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (g.sessionName != null) ...[
                          const SizedBox(height: 2),
                          SimpleText(
                            text: g.sessionName!,
                            size: 12,
                            color: onGrey300,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _CountChip(
                              label: '${g.availableCount} dispo',
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 6),
                            _CountChip(
                              label: '${g.usedCount} utilisé'
                                  '${g.usedCount > 1 ? 's' : ''}',
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: onGrey300,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            ...g.codes.map((c) => _CodeTile(code: c)),
          ],
        ],
      ),
    );
  }

  Widget _logoPlaceholder() => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: prepaPrimaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.school_rounded,
            color: prepaPrimaryColor, size: 22),
      );
}

class _CountChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CountChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SimpleText(
        text: label,
        size: 11,
        weight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// ── Ligne d'un code ──────────────────────────────────────────────────────────

class _CodeTile extends StatelessWidget {
  final SubscriptionCodeModel code;
  const _CodeTile({required this.code});

  @override
  Widget build(BuildContext context) {
    final used = code.isUsed;
    final fmt = DateFormat('dd/MM/yyyy à HH:mm');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Le code lui-même
              Expanded(
                child: SimpleText(
                  text: code.formatted,
                  size: 16,
                  weight: FontWeight.bold,
                  letterspacing: 2,
                  color: used ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(used: used),
              if (!used) ...[
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  tooltip: 'Copier le code',
                  icon: const Icon(Icons.copy_rounded,
                      size: 17, color: prepaPrimaryColor),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code.formatted));
                    Notify.toastSuccess('Code ${code.formatted} copié');
                  },
                ),
              ],
            ],
          ),

          // Détails d'utilisation
          if (used) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Expanded(
                  child: SimpleText(
                    text: code.usedByName ?? 'Utilisateur inconnu',
                    size: 12,
                    color: onGrey300,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (code.usedAt != null) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 5),
                  Flexible(
                    child: SimpleText(
                      text: 'Activé le ${fmt.format(code.usedAt!)}',
                      size: 12,
                      color: onGrey300,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool used;
  const _StatusPill({required this.used});

  @override
  Widget build(BuildContext context) {
    final color = used ? Colors.grey.shade500 : Colors.green.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SimpleText(
        text: used ? 'Utilisé' : 'Disponible',
        size: 10,
        weight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

// ── État vide ────────────────────────────────────────────────────────────────

class _EmptyCodes extends StatelessWidget {
  const _EmptyCodes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            const SimpleText(
              text: 'Aucun code',
              size: 16,
              weight: FontWeight.bold,
              align: TextAlign.center,
            ),
            const SizedBox(height: 6),
            SimpleText(
              text: 'Achetez plusieurs places pour un concours '
                  'et recevez des codes à partager.',
              size: 13,
              color: onGrey300,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
