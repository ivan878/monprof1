import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_code_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class MesCodesController extends ChangeNotifier {
  final SubscriptionRepository repository;

  MesCodesController({required this.repository});

  AppState<List<SubscriptionCodeGroupModel>> state = AppState();

  List<SubscriptionCodeGroupModel> get groups => state.data ?? const [];

  int get totalCodes =>
      groups.fold(0, (sum, g) => sum + g.totalCount);

  int get totalAvailable =>
      groups.fold(0, (sum, g) => sum + g.availableCount);

  Future<void> loadCodes({bool silent = false}) async {
    if (!silent) {
      state = AppState(status: AppStatus.loading);
      notifyListeners();
    }
    state = await repository.listMyCodeGroups();
    notifyListeners();
  }

  Future<void> refresh() => loadCodes(silent: true);
}
