// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/cours/controllers/matieres_controller.dart';
import 'package:monprof/prepa/cours/data/models/matiere_model.dart';
import 'package:monprof/prepa/cours/screens/matiere_detail_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class MatieresScreen extends StatefulWidget {
  const MatieresScreen({super.key});

  @override
  State<MatieresScreen> createState() => _MatieresScreenState();
}

class _MatieresScreenState extends State<MatieresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<MatieresController>();
      if (ctrl.items.isEmpty) ctrl.loadMatieres();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatieresController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const SimpleText(
              text: 'Matières',
              size: 20,
              weight: FontWeight.bold,
            ),
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          backgroundColor: grey300,
          body: _buildBody(context, controller),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MatieresController controller) {
    if (controller.state.isLoading && controller.items.isEmpty) {
      return const Loading();
    }

    if (controller.state.hasError && controller.items.isEmpty) {
      return ErrorPage(
        errorMessage:
            controller.state.errorModel?.error ?? 'Erreur de chargement',
        reload: controller.loadMatieres,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: primaryColor,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 300 &&
              !controller.state.isLoading &&
              controller.hasMore) {
            controller.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: controller.items.length + (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _MatiereCard(
              matiere: controller.items[index],
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: MatiereDetailScreen(
                      matiere: controller.items[index],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MatiereCard extends StatelessWidget {
  final MatiereModel matiere;
  final VoidCallback onTap;

  const _MatiereCard({required this.matiere, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: matiere.logoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: matiere.logoUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _placeholder(),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SimpleText(
                text: matiere.name ?? 'Matière',
                size: 14,
                weight: FontWeight.bold,
                align: TextAlign.center,
                maxlines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (matiere.description != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SimpleText(
                  text: matiere.description!,
                  size: 11,
                  color: onGrey300,
                  align: TextAlign.center,
                  maxlines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.book_rounded, color: primaryColor, size: 32),
    );
  }
}
