import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/subscription/data/models/transaction_model.dart';
import 'package:monprof/prepa/subscription/data/repository/subscription_repository.dart';

class MesTransactionsController extends ChangeNotifier {
  final SubscriptionRepository repository;

  MesTransactionsController({required this.repository});

  AppState<PrepaPage<TransactionModel>> state = AppState();
  int currentPage = 0;
  bool hasMore = true;
  List<TransactionModel> items = [];

  Future<void> loadTransactions({bool refresh = false}) async {
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

    final result = await repository.listMyTransactions(page: currentPage);
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

  Future<void> refresh() => loadTransactions(refresh: true);
  Future<void> loadMore() => loadTransactions();
}
