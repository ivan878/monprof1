import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/local_storage/hive_service.dart';
import 'package:monprof/prepa/cours/data/models/cours_model.dart';
import 'package:monprof/prepa/cours/data/repository/cours_repository.dart';

class PrepaCoursDetailController extends ChangeNotifier {
  final PrepaCoursRepository repository;
  final HiveService hiveService;
  final String coursId;

  PrepaCoursDetailController({
    required this.repository,
    required this.hiveService,
    required this.coursId,
  });

  AppState<PrepaCoursModel> state = AppState();

  Future<void> load() async {
    final cached = hiveService.getCours(coursId);
    if (cached != null) {
      state = AppState(status: AppStatus.data, data: cached);
      notifyListeners();
    } else {
      state = AppState(status: AppStatus.loading);
      notifyListeners();
    }

    final result = await repository.getCoursById(coursId);
    if (result.hasData) {
      hiveService.saveCours(result.data!);
      state = result;
    } else if (cached == null) {
      state = result;
    }
    notifyListeners();
  }

  Future<void> refresh() => load();
}
