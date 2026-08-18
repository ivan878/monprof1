import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/app_bouton.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/common/prepa_theme.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/screens/concours_detail_screen.dart';
import 'package:monprof/prepa/home/home_controller.dart';
import 'package:monprof/prepa/home/widgets/home_empty_state.dart';
import 'package:page_transition/page_transition.dart';

class HomeConcoursScroll extends StatelessWidget {
  final HomeController ctrl;
  const HomeConcoursScroll({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.concoursState.isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final concours = ctrl.concoursState.data ?? [];
    if (concours.isEmpty) {
      return const HomeEmptyState(
        icon: Icons.school_outlined,
        title: 'Aucun concours en cours',
        subtitle: 'Les concours disponibles apparaîtront ici',
      );
    }

    // Cap at 10 cards to avoid excessive image decodes.
    final visible = concours.take(10).toList();

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: visible.length,
        itemBuilder: (ctx, i) => HomeConcoursCard(concours: visible[i]),
      ),
    );
  }
}

class HomeConcoursCard extends StatelessWidget {
  final ConcoursModel concours;
  const HomeConcoursCard({super.key, required this.concours});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: ConcoursDetailScreen(concoursId: concours.id),
        ),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: concours.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: concours.logoUrl!,
                      width: 200,
                      height: 120,
                      fit: BoxFit.cover,
                      // memCacheWidth: 180,
                      // memCacheHeight: 120,
                      // color: red,
                      errorWidget: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 5),
                  SimpleText(
                    text: concours.name ?? 'Concours',
                    size: 12,
                    weight: FontWeight.bold,
                    maxlines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  DefaultButton(
                    text: 'Voir le concours',
                    width: double.infinity,
                    height: 40,
                    color: Colors.white,
                    backgroundColor: prepaPrimaryColor,
                    fontSize: 12,
                    radius: 8,
                    onPressed: () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: ConcoursDetailScreen(concoursId: concours.id),
                      ),
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

  Widget _imgPlaceholder() {
    return Container(
      width: 180,
      height: 120,
      color: prepaPrimaryColor.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(27),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: primaryColor.withValues(alpha: 0.12),
          child: const Icon(Icons.school_rounded,
              color: prepaPrimaryColor, size: 36),
        ),
      ),
    );
  }
}
