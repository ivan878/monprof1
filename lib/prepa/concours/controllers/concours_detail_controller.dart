import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';

class ConcoursDetailController extends ChangeNotifier {
  final ConcoursRepository repository;
  final String concoursId;

  ConcoursDetailController({
    required this.repository,
    required this.concoursId,
  });

  AppState<ConcoursModel> state = AppState();

  Future<void> load() async {
    try {
      state = AppState(status: AppStatus.loading);
      notifyListeners();
      state = await repository.getConcoursById(concoursId);
      notifyListeners();
    } catch (e) {
      state = AppState(status: AppStatus.error, errorModel: state.errorModel);
      notifyListeners();
    }
  }

  Future<void> refresh() => load();
}
