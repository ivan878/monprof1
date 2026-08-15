import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';
import 'package:monprof/prepa/concours/screens/cours_concours_detail_screen.dart';
import 'package:monprof/prepa/cours/controllers/cours_list_controller.dart';
import 'package:monprof/prepa/cours/data/models/cours_model.dart';
import 'package:monprof/prepa/cours/data/models/matiere_model.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';
import 'package:page_transition/page_transition.dart';

class MatiereDetailScreen extends StatefulWidget {
  final MatiereModel matiere;
  final ConcoursModel? concours;

  const MatiereDetailScreen({
    super.key,
    required this.matiere,
    this.concours,
  });

  @override
  State<MatiereDetailScreen> createState() => _MatiereDetailScreenState();
}

class _MatiereDetailScreenState extends State<MatiereDetailScreen> {
  late final PrepaCoursListController _coursCtrl;
  ConcoursModel? _resolvedConcours;

  @override
  void initState() {
    super.initState();
    _coursCtrl = PrepaCoursListController(
      repository: GetIt.instance<PrepaCoursRepository>(),
      hiveService: GetIt.instance(),
      matiereId: widget.matiere.id,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _coursCtrl.loadCours();
      if (widget.concours != null) _resolveConcours();
    });
  }

  Future<void> _resolveConcours() async {
    final c = widget.concours!;
    if (c.activeSession != null) {
      if (mounted) setState(() => _resolvedConcours = c);
      return;
    }
    final hive = GetIt.instance<HiveService>();
    final cached = hive.getConcoursDetail(c.id);
    if (cached?.activeSession != null) {
      if (mounted) setState(() => _resolvedConcours = cached);
      return;
    }
    final result =
        await GetIt.instance<ConcoursRepository>().getConcoursById(c.id);
    if (result.hasData && result.data != null) {
      hive.saveConcoursDetail(result.data!);
      if (mounted) setState(() => _resolvedConcours = result.data);
    }
  }

  @override
  void dispose() {
    _coursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _coursCtrl,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: grey300,
          body: NotificationListener<ScrollEndNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 300 &&
                  !_coursCtrl.state.isLoading &&
                  _coursCtrl.hasMore) {
                _coursCtrl.loadMore();
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: _coursCtrl.refresh,
              color: prepaPrimaryColor,
              child: CustomScrollView(
                slivers: [
                  _buildBanner(context),
                  _buildInfoSection(),
                  _buildCoursSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Bannière ────────────────────────────────────────────────────────────────

  SliverAppBar _buildBanner(BuildContext context) {
    final matiere = widget.matiere;
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: prepaPrimaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Fond : image ou couleur
            matiere.logoUrl != null
                ? CachedNetworkImage(
                    imageUrl: matiere.logoUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.45),
                    colorBlendMode: BlendMode.darken,
                    placeholder: (_, __) => _bannerPlaceholder(),
                    errorWidget: (_, __, ___) => _bannerPlaceholder(),
                  )
                : _bannerPlaceholder(),
            // Dégradé bas
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Logo rond centré + titre en bas
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: matiere.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: matiere.logoUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _logoIcon(),
                            ),
                          )
                        : _logoIcon(),
                  ),
                  const SizedBox(width: 14),
                  // Nom + badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (matiere.isActive == true)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const SimpleText(
                              text: 'ACTIVE',
                              size: 10,
                              weight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        SimpleText(
                          text: matiere.name ?? 'Matière',
                          size: 20,
                          weight: FontWeight.bold,
                          color: Colors.white,
                          maxlines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [prepaPrimaryColor, prepaPrimaryDark],
        ),
      ),
      child: const Center(
        child: Icon(Icons.menu_book_rounded, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _logoIcon() {
    return const Icon(Icons.menu_book_rounded,
        color: Colors.white, size: 32);
  }

  // ── Section info (description) ───────────────────────────────────────────────

  Widget _buildInfoSection() {
    final matiere = widget.matiere;
    final hasDescription =
        matiere.description != null && matiere.description!.isNotEmpty;

    if (!hasDescription) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _cardShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SimpleText(
                text: 'À PROPOS DE CETTE MATIÈRE',
                size: 11,
                weight: FontWeight.bold,
                color: Color(0xFF8E8E8E),
              ),
              const SizedBox(height: 10),
              SimpleText(
                text: matiere.description!,
                size: 14,
                color: darkColorSecond,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section cours ─────────────────────────────────────────────────────────

  Widget _buildCoursSection() {
    // Chargement initial
    if (_coursCtrl.state.isLoading && _coursCtrl.items.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Erreur sans données
    if (_coursCtrl.state.hasError && _coursCtrl.items.isEmpty) {
      return SliverFillRemaining(
        child: ErrorPage(
          errorMessage:
              _coursCtrl.state.errorModel?.error ?? 'Erreur de chargement',
          reload: _coursCtrl.loadCours,
        ),
      );
    }

    // Header + liste + load-more
    return SliverMainAxisGroup(
      slivers: [
        // En-tête section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: prepaPrimaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                SimpleText(
                  text: 'COURS DISPONIBLES',
                  size: 12,
                  weight: FontWeight.bold,
                  color: darkColorSecond,
                ),
                const Spacer(),
                if (_coursCtrl.items.isNotEmpty)
                  SimpleText(
                    text: '${_coursCtrl.items.length} cours',
                    size: 12,
                    color: const Color(0xFF8E8E8E),
                  ),
              ],
            ),
          ),
        ),

        // Liste vide
        if (_coursCtrl.items.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _cardShadow(),
                ),
                child: Column(
                  children: [
                    Icon(Icons.library_books_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    SimpleText(
                      text: 'Aucun cours disponible',
                      size: 14,
                      weight: FontWeight.w600,
                      color: const Color(0xFF8E8E8E),
                    ),
                    const SizedBox(height: 4),
                    SimpleText(
                      text: 'Les cours pour cette matière apparaîtront ici',
                      size: 12,
                      color: Colors.grey.shade400,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Cartes cours
        if (_coursCtrl.items.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cours = _coursCtrl.items[index];
                  return _CoursCard(
                    cours: cours,
                    isLast: index == _coursCtrl.items.length - 1,
                    onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: CoursConcoursDetailScreen(
                          coursId: cours.id,
                          concours: _resolvedConcours,
                        ),
                      ),
                    ),
                  );
                },
                childCount: _coursCtrl.items.length,
              ),
            ),
          ),

        // Indicateur load-more
        if (_coursCtrl.hasMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

// ── Carte cours ───────────────────────────────────────────────────────────────

class _CoursCard extends StatelessWidget {
  final PrepaCoursModel cours;
  final bool isLast;
  final VoidCallback onTap;

  const _CoursCard({
    required this.cours,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = cours.videoUrl != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icône type
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isVideo
                      ? Colors.red.withValues(alpha: 0.10)
                      : prepaPrimaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isVideo
                      ? Icons.play_circle_filled_rounded
                      : Icons.menu_book_rounded,
                  color: isVideo ? Colors.red.shade700 : prepaPrimaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Titre + résumé + badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleText(
                      text: cours.title ?? 'Cours sans titre',
                      size: 14,
                      weight: FontWeight.w600,
                      maxlines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cours.body != null && cours.body!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      SimpleText(
                        text: cours.body!,
                        size: 12,
                        color: onGrey300,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _SmallBadge(
                          label: cours.gratuit ? 'Gratuit' : 'Premium',
                          color: cours.gratuit
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          bg: cours.gratuit
                              ? Colors.green.withValues(alpha: 0.10)
                              : Colors.orange.withValues(alpha: 0.10),
                        ),
                        if (isVideo) ...[
                          const SizedBox(width: 6),
                          _SmallBadge(
                            label: 'Vidéo',
                            icon: Icons.play_arrow_rounded,
                            color: Colors.red.shade600,
                            bg: Colors.red.withValues(alpha: 0.08),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Flèche + icône téléchargement
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded,
                      size: 18, color: prepaPrimaryColor),
                  const SizedBox(height: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: onGrey300),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color bg;

  const _SmallBadge({
    required this.label,
    this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          SimpleText(
            text: label,
            size: 10,
            weight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── Utilitaires ───────────────────────────────────────────────────────────────

List<BoxShadow> _cardShadow() => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];
