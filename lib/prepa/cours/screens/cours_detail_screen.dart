// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/cours/controllers/cours_detail_controller.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursDetailScreen extends StatefulWidget {
  final String coursId;

  const CoursDetailScreen({super.key, required this.coursId});

  @override
  State<CoursDetailScreen> createState() => _CoursDetailScreenState();
}

class _CoursDetailScreenState extends State<CoursDetailScreen> {
  late final PrepaCoursDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PrepaCoursDetailController(
      repository: GetIt.instance<PrepaCoursRepository>(),
      hiveService: GetIt.instance(),
      coursId: widget.coursId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.load());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _launchVideo(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
        final hasVideo = cours.videoUrl != null;
        final hasBody = cours.body != null && cours.body!.isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: SimpleText(
              text: cours.title ?? 'Cours',
              size: 17,
              weight: FontWeight.bold,
              maxlines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _ctrl.refresh,
            color: primaryColor,
            child: ListView(
              children: [
                // ── Badges ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _Badge(
                        label: cours.gratuit ? 'Gratuit' : 'Premium',
                        color: cours.gratuit
                            ? Colors.green.shade700
                            : Colors.amber.shade800,
                        bg: cours.gratuit
                            ? Colors.green.shade50
                            : Colors.amber.shade50,
                      ),
                      if (hasVideo) ...[
                        const SizedBox(width: 8),
                        _Badge(
                          label: 'Vidéo',
                          color: primaryColor,
                          bg: primaryColor.withValues(alpha: 0.08),
                          icon: Icons.play_arrow_rounded,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Zone vidéo ───────────────────────────────────────────────
                if (hasVideo) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onTap: () => _launchVideo(cours.videoUrl!),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_circle_outline_rounded,
                                size: 56,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 10),
                              SimpleText(
                                text: 'Regarder la vidéo',
                                size: 14,
                                color: primaryColor,
                                weight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Contenu texte ─────────────────────────────────────────────
                if (hasBody) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SimpleText(
                      text: 'CONTENU',
                      size: 11,
                      weight: FontWeight.bold,
                      color: onGrey300,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SimpleText(
                      text: cours.body!,
                      size: 15,
                      color: darkColorSecond,
                    ),
                  ),
                ],

                // ── Bouton navigateur ─────────────────────────────────────────
                if (hasVideo) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DefaultButton(
                      text: 'Ouvrir dans le navigateur',
                      onPressed: () => _launchVideo(cours.videoUrl!),
                      wdiget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.open_in_new_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          const SimpleText(
                            text: 'Ouvrir la vidéo',
                            color: Colors.white,
                            size: 15,
                            weight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
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
