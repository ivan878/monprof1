import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/subscription/data/models/subscription_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class MesSubscriptionsController extends ChangeNotifier {
  final SubscriptionRepository repository;
  final String? statusFilter;

  MesSubscriptionsController({required this.repository, this.statusFilter});

  AppState<PrepaPage<SubscriptionModel>> state = AppState();
  int currentPage = 0;
  bool hasMore = true;
  List<SubscriptionModel> items = [];

  Future<void> loadSubscriptions({bool refresh = false}) async {
    if (refresh) {
      currentPage = 0;
      items = [];
      hasMore = true;
    }
    if (!hasMore) return;
    if (currentPage == 0 && items.isEmpty) {
      state = AppState(status: AppStatus.loading);
    }
    notifyListeners();

    AppState<PrepaPage<SubscriptionModel>> result;
    if (statusFilter != null) {
      result = await repository.listMySubscriptionsByStatus(
        statusFilter!,
        page: currentPage,
      );
    } else {
      result = await repository.listMySubscriptions(page: currentPage);
    }

    if (result.hasData) {
      items.addAll(result.data!.content);
      hasMore = !result.data!.last;
      currentPage++;
      state = AppState(status: AppStatus.data, data: result.data);
    } else {
      state = result;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadSubscriptions(refresh: true);
  Future<void> loadMore() => loadSubscriptions();
}
