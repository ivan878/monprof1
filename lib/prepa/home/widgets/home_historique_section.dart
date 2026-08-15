import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/cours/screens/video_player_screen.dart';
import 'package:monprof/prepa/home/home_controller.dart';
import 'package:monprof/prepa/home/widgets/home_empty_state.dart';
import 'package:page_transition/page_transition.dart';

class HomeHistoriqueSection extends StatelessWidget {
  final HomeController ctrl;
  const HomeHistoriqueSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final history = ctrl.videoHistory;

    if (history.isEmpty) {
      return const HomeEmptyState(
        icon: Icons.play_circle_outline_rounded,
        title: 'Aucune vidéo en cours',
        subtitle: 'Les vidéos que vous commencez apparaîtront ici',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: history
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _VideoHistoryTile(
                    entry: entry,
                    onReturn: ctrl.refreshVideoHistory,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _VideoHistoryTile extends StatelessWidget {
  final PlaybackEntry entry;
  final VoidCallback onReturn;
  const _VideoHistoryTile({required this.entry, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final hasDuration = entry.totalMs > 0;
    final progress =
        hasDuration ? (entry.positionMs / entry.totalMs).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).round();

    return GestureDetector(
      onTap: entry.filePath != null
          ? () async {
              await Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: VideoPlayerScreen(
                    filePath: entry.filePath!,
                    coursId: entry.coursId,
                    matiereId: entry.matiereId,
                    title: entry.title,
                    videoUrl: entry.videoUrl,
                  ),
                ),
              );
              // Recharge l'historique : la position vient de changer
              onReturn();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            // Thumbnail placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: prepaPrimaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.ondemand_video_rounded,
                    color: prepaPrimaryColor,
                    size: 30,
                  ),
                  // Mini progress arc
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          prepaPrimaryColor.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SimpleText(
                    text: entry.title ?? 'Cours vidéo',
                    size: 14,
                    weight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    maxlines: 2,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(prepaPrimaryColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SimpleText(
                    text:
                        hasDuration ? '$pct% visionné' : 'En cours de lecture',
                    size: 11,
                    color: onGrey300,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.play_arrow_rounded, color: prepaPrimaryColor, size: 28),
          ],
        ),
      ),
    );
  }
}
