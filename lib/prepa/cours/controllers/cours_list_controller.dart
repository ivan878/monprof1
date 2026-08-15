import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/cours/data/models/cours_model.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';

class PrepaCoursListController extends ChangeNotifier {
  final PrepaCoursRepository repository;
  final HiveService hiveService;
  final String? matiereId;

  PrepaCoursListController({
    required this.repository,
    required this.hiveService,
    this.matiereId,
  });

  AppState<PrepaPage<PrepaCoursModel>> state = AppState();
  int currentPage = 0;
  bool hasMore = true;
  List<PrepaCoursModel> items = [];

  Future<void> loadCours({bool refresh = false}) async {
    if (refresh) {
      currentPage = 0;
      items = [];
      hasMore = true;
    }
    if (!hasMore) return;

    final isFirstPage = currentPage == 0;

    if (isFirstPage && items.isEmpty) {
      // Show cached data immediately (only for matiere-scoped lists)
      if (matiereId != null) {
        final cached = hiveService.getCoursByMatiereId(matiereId!);
        if (cached.isNotEmpty) {
          items = cached;
          state = AppState(status: AppStatus.data);
          notifyListeners();
        } else {
          state = AppState(status: AppStatus.loading);
          notifyListeners();
        }
      } else {
        state = AppState(status: AppStatus.loading);
        notifyListeners();
      }
    }

    AppState<PrepaPage<PrepaCoursModel>> result;
    if (matiereId != null) {
      result = await repository.getCoursByMatiereId(
        matiereId!,
        page: currentPage,
      );
    } else {
      result = await repository.listCours(page: currentPage);
    }

    if (result.hasData) {
      final page = result.data!;
      if (isFirstPage) {
        items = page.content;
        if (matiereId != null) {
          hiveService.saveCoursByMatiereId(matiereId!, items);
        }
      } else {
        items.addAll(page.content);
      }
      hasMore = !page.last;
      currentPage++;
      state = AppState(status: AppStatus.data, data: result.data);
    } else {
      if (items.isEmpty) state = result;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadCours(refresh: true);
  Future<void> loadMore() => loadCours();
}
