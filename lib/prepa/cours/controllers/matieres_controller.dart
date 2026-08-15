import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/cours/data/models/matiere_model.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';

class MatieresController extends ChangeNotifier {
  final PrepaCoursRepository repository;
  final HiveService hiveService;

  MatieresController({
    required this.repository,
    required this.hiveService,
  });

  AppState<PrepaPage<MatiereModel>> state = AppState();
  int currentPage = 1;
  bool hasMore = true;
  List<MatiereModel> items = [];

  Future<void> loadMatieres({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      items = [];
      hasMore = true;
    }
    if (!hasMore) return;

    final isFirstPage = currentPage == 1;

    if (isFirstPage) {
      final cached = hiveService.getMatieresList();
      if (cached.isNotEmpty) {
        items = cached;
        state = AppState(status: AppStatus.data);
        notifyListeners();
      } else {
        state = AppState(status: AppStatus.loading);
        notifyListeners();
      }
    }

    final result = await repository.listMatieres(page: currentPage);
    if (result.hasData) {
      final page = result.data!;
      if (isFirstPage) {
        items = page.content;
        hiveService.saveMatieresList(items);
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

  Future<void> refresh() => loadMatieres(refresh: true);
  Future<void> loadMore() => loadMatieres();
}
