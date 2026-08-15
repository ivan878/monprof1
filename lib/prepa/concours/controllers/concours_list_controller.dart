import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';

class ConcoursListController extends ChangeNotifier {
  final ConcoursRepository repository;
  final HiveService hiveService;

  ConcoursListController({
    required this.repository,
    required this.hiveService,
  });

  AppState<PrepaPage<ConcoursModel>> state = AppState();
  int currentPage = 1;
  bool hasMore = true;
  List<ConcoursModel> items = [];

  Future<void> loadConcours({bool refresh = false}) async {
    if (state.isLoading) return;
    if (refresh) {
      currentPage = 1;
      items = [];
      hasMore = true;
    }
    if (!hasMore) return;

    final isFirstPage = currentPage == 1;

    if (isFirstPage) {
      final cached = hiveService.getConcoursList();
      if (cached.isNotEmpty) {
        items = cached;
        state = AppState(status: AppStatus.data);
        notifyListeners();
      } else {
        state = AppState(status: AppStatus.loading);
        notifyListeners();
      }
    }

    final result = await repository.listConcours(page: currentPage);
    if (result.hasData) {
      final page = result.data!;
      if (isFirstPage) {
        items = page.content;
        hiveService.saveConcoursList(items);
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

  Future<void> refresh() => loadConcours(refresh: true);
  Future<void> loadMore() => loadConcours();
}
