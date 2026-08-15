// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/concours/controllers/concours_list_controller.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/screens/concours_detail_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ConcoursListScreen extends StatefulWidget {
  const ConcoursListScreen({super.key});

  @override
  State<ConcoursListScreen> createState() => _ConcoursListScreenState();
}

class _ConcoursListScreenState extends State<ConcoursListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<ConcoursListController>();
      if (ctrl.items.isEmpty) ctrl.loadConcours();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConcoursListController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const SimpleText(
              text: 'Concours',
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

  Widget _buildBody(BuildContext context, ConcoursListController controller) {
    if (controller.state.isLoading && controller.items.isEmpty) {
      return const Loading();
    }

    if (controller.state.hasError && controller.items.isEmpty) {
      return ErrorPage(
        errorMessage:
            controller.state.errorModel?.error ?? 'Erreur de chargement',
        reload: controller.loadConcours,
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.items.length + (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _ConcoursCard(
              concours: controller.items[index],
              onTap: () => Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ConcoursDetailScreen(
                    concoursId: controller.items[index].id,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConcoursCard extends StatelessWidget {
  final ConcoursModel concours;
  final VoidCallback onTap;

  const _ConcoursCard({required this.concours, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: concours.logoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: concours.logoUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        memCacheWidth: 120,
                        memCacheHeight: 120,
                        placeholder: (_, __) => _logoPlaceholder(),
                        errorWidget: (_, __, ___) => _logoPlaceholder(),
                      )
                    : _logoPlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleText(
                      text: concours.name ?? 'Concours',
                      size: 16,
                      weight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                      maxlines: 2,
                    ),
                    if (concours.description != null) ...[
                      const SizedBox(height: 4),
                      SimpleText(
                        text: concours.description!,
                        size: 13,
                        color: onGrey300,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (concours.isActive == true
                                ? Colors.green
                                : Colors.grey)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SimpleText(
                        text: concours.isActive == true ? 'Actif' : 'Inactif',
                        size: 11,
                        weight: FontWeight.w600,
                        color: concours.isActive == true
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: onGrey300),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.school_rounded, color: primaryColor, size: 32),
    );
  }
}
