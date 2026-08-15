// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/auth/data/services/prepa_api_client.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/cours/controllers/cours_detail_controller.dart';
import 'package:monprof/prepa/cours/data/models/cours_model.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';
import 'package:monprof/prepa/cours/screens/video_player_screen.dart';
import 'package:monprof/prepa/subscription/screens/payment_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

class CoursConcoursDetailScreen extends StatefulWidget {
  final String coursId;
  // Optionnel : concours parent (avec activeSession) pour le CTA de souscription
  final ConcoursModel? concours;

  const CoursConcoursDetailScreen({
    super.key,
    required this.coursId,
    this.concours,
  });

  @override
  State<CoursConcoursDetailScreen> createState() =>
      _CoursConcoursDetailScreenState();
}

class _CoursConcoursDetailScreenState extends State<CoursConcoursDetailScreen> {
  late final PrepaCoursDetailController _ctrl;
  late final HiveService _hiveService;

  bool _isDownloading = false;
  double _progress = 0.0;
  bool _downloadComplete = false;
  String? _downloadError;
  CancelToken? _cancelToken;

  // Local video file path — non-null means the video is available offline
  String? _localFilePath;
  bool _cacheChecked = false;

  @override
  void initState() {
    super.initState();
    _hiveService = GetIt.instance<HiveService>();
    _ctrl = PrepaCoursDetailController(
      repository: GetIt.instance<PrepaCoursRepository>(),
      hiveService: _hiveService,
      coursId: widget.coursId,
    );
    _ctrl.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.load());
  }

  void _onControllerChanged() {
    if (_ctrl.state.hasData && !_cacheChecked && _ctrl.state.data != null) {
      _cacheChecked = true;
      _checkVideoCache(_ctrl.state.data!);
    }
  }

  Future<void> _checkVideoCache(PrepaCoursModel cours) async {
    if (cours.videoUrl == null) return;

    final cache = _hiveService.getVideoCache(cours.id, cours.matiereId);
    if (cache == null) return;

    // URL changed → invalidate
    if (cache.videoUrl != cours.videoUrl) {
      _hiveService.deleteVideoCache(cours.id, cours.matiereId);
      return;
    }

    // Verify file still on disk
    if (!await File(cache.filePath).exists()) {
      _hiveService.deleteVideoCache(cours.id, cours.matiereId);
      return;
    }

    if (mounted) setState(() => _localFilePath = cache.filePath);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _cancelToken?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _startDownload(PrepaCoursModel cours) async {
    final url = cours.videoUrl;
    if (url == null || _isDownloading) return;

    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _downloadComplete = false;
      _downloadError = null;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = _extensionFromUrl(url);
      // Deterministic filename: never re-downloaded unless URL changes or file missing
      final key = '${cours.id}_${cours.matiereId ?? 'none'}';
      final savePath = '${dir.path}/$key.$ext';

      _cancelToken = CancelToken();
      final dio = GetIt.instance<PrepaApiClient>().dio;

      await dio.download(
        url,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _progress = received / total);
          }
        },
      );

      // Persist in local cache
      _hiveService.saveVideoCache(cours.id, cours.matiereId, savePath, url);

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadComplete = true;
          _progress = 1.0;
          _localFilePath = savePath;
        });
        await _openVideoPlayer(cours, savePath);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (mounted) setState(() => _isDownloading = false);
      } else {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _downloadError =
                'Échec du téléchargement. Vérifiez votre connexion.';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadError = 'Une erreur est survenue.';
        });
      }
    }
  }

  Future<void> _openVideoPlayer(PrepaCoursModel cours, String filePath) async {
    await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: VideoPlayerScreen(
          filePath: filePath,
          title: cours.title,
          coursId: cours.id,
          matiereId: cours.matiereId,
          videoUrl: cours.videoUrl,
        ),
      ),
    );
    // La progression de lecture est lue depuis Hive au moment du build :
    // sans ce rebuild, la carte afficherait encore l'ancienne position.
    if (mounted) setState(() {});
  }

  String _extensionFromUrl(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot != -1 && dot < path.length - 1) {
      final ext = path.substring(dot + 1).toLowerCase();
      if (ext.length <= 5) return ext;
    }
    return 'mp4';
  }

  void _cancelDownload() {
    _cancelToken?.cancel("Annulé par l'utilisateur");
    setState(() => _isDownloading = false);
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
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: ErrorPage(
              errorMessage:
                  _ctrl.state.errorModel?.error ?? 'Erreur de chargement',
              reload: _ctrl.load,
            ),
          );
        }

        final cours = _ctrl.state.data!;

        return Scaffold(
          backgroundColor: grey300,
          body: CustomScrollView(
            slivers: [
              _buildBanner(cours),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BadgesRow(cours: cours),
                      const SizedBox(height: 14),
                      if (cours.body != null && cours.body!.isNotEmpty) ...[
                        _ContentCard(body: cours.body!),
                        const SizedBox(height: 14),
                      ],
                      _DownloadCard(
                        cours: cours,
                        concours: widget.concours,
                        localFilePath: _localFilePath,
                        isDownloading: _isDownloading,
                        progress: _progress,
                        downloadComplete: _downloadComplete,
                        error: _downloadError,
                        hiveService: _hiveService,
                        onDownload: () => _startDownload(cours),
                        onCancel: _cancelDownload,
                        onPlay: _localFilePath != null
                            ? () => _openVideoPlayer(cours, _localFilePath!)
                            : null,
                      ),
                      const SizedBox(height: 14),
                      const _CommentsLikesSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildBanner(PrepaCoursModel cours) {
    final isVideo = cours.videoUrl != null;
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: prepaPrimaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFB71C1C), const Color(0xFF880E4F)],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVideo
                          ? Icons.play_circle_filled_rounded
                          : Icons.menu_book_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SimpleText(
                      text: cours.title ?? 'Cours',
                      size: 18,
                      weight: FontWeight.bold,
                      color: Colors.white,
                      align: TextAlign.center,
                      maxlines: 2,
                      overflow: TextOverflow.ellipsis,
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
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _BadgesRow extends StatelessWidget {
  final PrepaCoursModel cours;
  const _BadgesRow({required this.cours});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Badge(
          label: cours.gratuit ? '✓ Gratuit' : '★ Premium',
          color: cours.gratuit ? Colors.green.shade700 : Colors.orange.shade700,
          bg: cours.gratuit
              ? Colors.green.withValues(alpha: 0.10)
              : Colors.orange.withValues(alpha: 0.10),
        ),
        if (cours.videoUrl != null)
          _Badge(
            label: 'Vidéo disponible',
            icon: Icons.play_circle_outline_rounded,
            color: Colors.red.shade700,
            bg: Colors.red.withValues(alpha: 0.10),
          ),
        if (cours.isActive == true)
          _Badge(
            label: 'Actif',
            icon: Icons.check_circle_outline_rounded,
            color: Colors.green.shade700,
            bg: Colors.green.withValues(alpha: 0.10),
          )
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color bg;

  const _Badge({
    required this.label,
    this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          SimpleText(
            text: label,
            size: 12,
            weight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── Contenu ───────────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final String body;
  const _ContentCard({required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SimpleText(
            text: 'CONTENU DU COURS',
            size: 11,
            weight: FontWeight.bold,
            color: onGrey300,
          ),
          const SizedBox(height: 10),
          SimpleText(text: body, size: 14, color: darkColorSecond),
        ],
      ),
    );
  }
}

// ── Téléchargement / Lecture ──────────────────────────────────────────────────

class _DownloadCard extends StatelessWidget {
  final PrepaCoursModel cours;
  final ConcoursModel? concours;
  final String? localFilePath;
  final bool isDownloading;
  final double progress;
  final bool downloadComplete;
  final String? error;
  final HiveService hiveService;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback? onPlay;

  const _DownloadCard({
    required this.cours,
    this.concours,
    this.localFilePath,
    required this.isDownloading,
    required this.progress,
    required this.downloadComplete,
    this.error,
    required this.hiveService,
    required this.onDownload,
    required this.onCancel,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                localFilePath != null
                    ? Icons.videocam_rounded
                    : Icons.download_for_offline_rounded,
                size: 18,
                color: localFilePath != null
                    ? Colors.green.shade600
                    : prepaPrimaryColor,
              ),
              const SizedBox(width: 8),
              SimpleText(
                text: localFilePath != null
                    ? 'VIDÉO HORS LIGNE'
                    : 'TÉLÉCHARGEMENT',
                size: 11,
                weight: FontWeight.bold,
                color: onGrey300,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (cours.videoUrl == null)
            _UnavailableState(concours: concours)
          else if (localFilePath != null)
            _CachedState(
              onPlay: onPlay!,
              coursId: cours.id,
              matiereId: cours.matiereId,
              hiveService: hiveService,
            )
          else if (isDownloading)
            _ProgressState(progress: progress, onCancel: onCancel)
          else
            _ReadyState(error: error, onDownload: onDownload),
        ],
      ),
    );
  }
}

class _UnavailableState extends StatelessWidget {
  final ConcoursModel? concours;
  const _UnavailableState({this.concours});

  @override
  Widget build(BuildContext context) {
    final hasSession = concours?.activeSession != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Badge "Contenu Premium"
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded,
                      size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  SimpleText(
                    text: 'Contenu Premium',
                    size: 12,
                    weight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Texte commercial
        SimpleText(
          text: 'Accédez à ce cours vidéo',
          size: 16,
          weight: FontWeight.bold,
          color: Colors.black87,
        ),
        const SizedBox(height: 6),
        SimpleText(
          text: hasSession
              ? 'Souscrivez à ${concours!.activeSession!.concoursName ?? concours!.name ?? 'ce concours'} '
                  'pour débloquer l\'ensemble des cours vidéo et maximiser vos chances de réussite.'
              : 'Inscrivez-vous au concours pour débloquer l\'ensemble des cours et ressources premium.',
          size: 13,
          color: onGrey300,
        ),

        if (hasSession) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.local_offer_rounded,
                  size: 14, color: prepaPrimaryColor),
              const SizedBox(width: 6),
              SimpleText(
                text:
                    '${concours!.activeSession!.amount?.toStringAsFixed(0) ?? '—'} FCFA / session',
                size: 13,
                weight: FontWeight.bold,
                color: prepaPrimaryColor,
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Bouton principal
        ElevatedButton.icon(
          onPressed: () {
            if (concours == null) return;
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: PaymentScreen(concours: concours!),
              ),
            );
          },
          icon: const Icon(Icons.lock_open_rounded, size: 20),
          label: Text(
            hasSession ? 'Souscrire au concours' : 'Voir les offres',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: prepaPrimaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),

        // Avantages
        const SizedBox(height: 14),
        ...[
          (Icons.play_circle_outline_rounded, 'Cours vidéo illimités'),
          (Icons.quiz_outlined, 'Exercices & annales'),
          (Icons.wifi_off_rounded, 'Accès hors ligne'),
        ].map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(item.$1, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 8),
                SimpleText(
                    text: item.$2, size: 13, color: Colors.grey.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CachedState extends StatelessWidget {
  final VoidCallback onPlay;
  final String coursId;
  final String? matiereId;
  final HiveService hiveService;

  const _CachedState({
    required this.onPlay,
    required this.coursId,
    this.matiereId,
    required this.hiveService,
  });

  @override
  Widget build(BuildContext context) {
    final saved = hiveService.getPlaybackPosition(coursId, matiereId);
    final hasSaved = saved != null && saved.positionMs > 0 && saved.totalMs > 0;
    final watchProgress =
        hasSaved ? (saved.positionMs / saved.totalMs).clamp(0.0, 1.0) : 0.0;
    final label = hasSaved ? 'Continuer la lecture' : 'Regarder maintenant';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.offline_bolt_rounded,
                  color: Colors.green.shade600, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleText(
                  text: 'Vidéo disponible hors ligne',
                  size: 14,
                  weight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                SimpleText(
                  text: 'Prête à être visionnée sans internet',
                  size: 12,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // ListTile-style play button with progress
        Material(
          color: Colors.green.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPlay,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    hasSaved
                        ? Icons.play_circle_rounded
                        : Icons.play_circle_outline_rounded,
                    color: Colors.green.shade600,
                    size: 38,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        if (hasSaved) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: watchProgress,
                              minHeight: 4,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green.shade500),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${(watchProgress * 100).round()}% visionné',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.green.shade400, size: 22),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadyState extends StatelessWidget {
  final String? error;
  final VoidCallback onDownload;

  const _ReadyState({this.error, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 16, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: SimpleText(
                    text: error!,
                    size: 12,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
        ElevatedButton.icon(
          onPressed: onDownload,
          icon: const Icon(Icons.download_rounded, size: 20),
          label: const Text(
            'Télécharger le cours',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: prepaPrimaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ── Comments & Likes placeholder ──────────────────────────────────────────────

class _CommentsLikesSection extends StatelessWidget {
  const _CommentsLikesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Likes row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.favorite_border_rounded,
                    color: Colors.red.shade300, size: 22),
                const SizedBox(width: 6),
                SimpleText(text: '0', size: 14, color: Colors.grey.shade600),
              ],
            ),
          ),
          const Divider(height: 24, indent: 16, endIndent: 16),
          // Questions header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    color: prepaPrimaryColor, size: 18),
                const SizedBox(width: 8),
                SimpleText(
                  text: 'QUESTIONS',
                  size: 11,
                  weight: FontWeight.bold,
                  color: onGrey300,
                ),
              ],
            ),
          ),
          // Empty state
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              children: [
                Icon(Icons.question_answer_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                SimpleText(
                  text: 'Soyez le premier à poser une question !',
                  size: 13,
                  color: onGrey300,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.add_comment_rounded,
                      size: 18, color: Colors.grey.shade400),
                  label: Text(
                    'Poser une question',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Download progress ─────────────────────────────────────────────────────────

class _ProgressState extends StatelessWidget {
  final double progress;
  final VoidCallback onCancel;

  const _ProgressState({required this.progress, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(
                    text: 'Téléchargement en cours…',
                    size: 13,
                    weight: FontWeight.w600,
                    color: prepaPrimaryColor,
                  ),
                  const SizedBox(height: 2),
                  SimpleText(
                    text: '$pct% complété',
                    size: 12,
                    color: onGrey300,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onCancel,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded,
                    size: 18, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: prepaPrimaryColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(prepaPrimaryColor),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: SimpleText(
            text: '$pct%',
            size: 12,
            weight: FontWeight.bold,
            color: prepaPrimaryColor,
          ),
        ),
      ],
    );
  }
}
