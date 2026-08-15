import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/concours/data/models/session_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';

class SessionListController extends ChangeNotifier {
  final ConcoursRepository repository;
  final String? concoursId;

  SessionListController({required this.repository, this.concoursId});

  AppState<PrepaPage<SessionModel>> state = AppState();
  int currentPage = 1;
  bool hasMore = true;
  List<SessionModel> items = [];

  Future<void> loadSessions({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      items = [];
      hasMore = true;
    }
    if (!hasMore) return;
    if (currentPage == 1) {
      state = AppState(status: AppStatus.loading);
    }
    notifyListeners();

    AppState<PrepaPage<SessionModel>> result;
    if (concoursId != null) {
      result = await repository.getSessionsByConcoursId(
        concoursId!,
        page: currentPage,
      );
    } else {
      result = await repository.listSessions(page: currentPage);
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

  Future<void> refresh() => loadSessions(refresh: true);
  Future<void> loadMore() => loadSessions();
}
