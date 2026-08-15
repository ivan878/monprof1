// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/corps/widgets/loading.dart';
import 'package:monprof/corps/widgets/simple_text.dart';
import 'package:monprof/corps/widgets/theme.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';
import 'package:monprof/prepa/concours/screens/cours_concours_detail_screen.dart';
import 'package:monprof/prepa/cours/controllers/cours_list_controller.dart';
import 'package:monprof/prepa/cours/data/models/cours_model.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';
import 'package:page_transition/page_transition.dart';

class CoursListScreen extends StatefulWidget {
  final String? matiereId;
  final String titre;
  final ConcoursModel? concours;

  const CoursListScreen({
    super.key,
    this.matiereId,
    this.titre = 'Cours',
    this.concours,
  });

  @override
  State<CoursListScreen> createState() => _CoursListScreenState();
}

class _CoursListScreenState extends State<CoursListScreen> {
  late final PrepaCoursListController _ctrl;
  ConcoursModel? _resolvedConcours;

  @override
  void initState() {
    super.initState();
    _ctrl = PrepaCoursListController(
      repository: GetIt.instance<PrepaCoursRepository>(),
      hiveService: GetIt.instance(),
      matiereId: widget.matiereId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadCours();
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
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: SimpleText(
              text: widget.titre,
              size: 20,
              weight: FontWeight.bold,
            ),
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          backgroundColor: grey300,
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_ctrl.state.isLoading && _ctrl.items.isEmpty) {
      return const Loading();
    }

    if (_ctrl.state.hasError && _ctrl.items.isEmpty) {
      return ErrorPage(
        errorMessage:
            _ctrl.state.errorModel?.error ?? 'Erreur de chargement',
        reload: _ctrl.loadCours,
      );
    }

    if (_ctrl.items.isEmpty) {
      return Center(
        child: SimpleText(
          text: 'Aucun cours disponible',
          size: 15,
          color: onGrey300,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _ctrl.refresh,
      color: primaryColor,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 300 &&
              !_ctrl.state.isLoading &&
              _ctrl.hasMore) {
            _ctrl.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _ctrl.items.length + (_ctrl.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _ctrl.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _CoursCard(
              cours: _ctrl.items[index],
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: CoursConcoursDetailScreen(
                      coursId: _ctrl.items[index].id,
                      concours: _resolvedConcours,
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

class _CoursCard extends StatelessWidget {
  final PrepaCoursModel cours;
  final VoidCallback onTap;

  const _CoursCard({required this.cours, required this.onTap});

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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cours.videoUrl != null
                      ? Colors.red.withValues(alpha: 0.1)
                      : primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  cours.videoUrl != null
                      ? Icons.play_circle_filled_rounded
                      : Icons.menu_book_rounded,
                  color: cours.videoUrl != null ? Colors.red : primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SimpleText(
                      text: cours.title ?? 'Cours',
                      size: 15,
                      weight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      maxlines: 2,
                    ),
                    if (cours.body != null) ...[
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: cours.gratuit
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SimpleText(
                            text: cours.gratuit ? 'Gratuit' : 'Premium',
                            size: 10,
                            weight: FontWeight.w600,
                            color: cours.gratuit
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                        if (cours.videoUrl != null) ...[
                          const SizedBox(width: 6),
                          SimpleText(
                            text: '• Vidéo',
                            size: 11,
                            color: Colors.red.shade400,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: onGrey300),
            ],
          ),
        ),
      ),
    );
  }
}
