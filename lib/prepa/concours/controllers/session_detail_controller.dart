import 'package:flutter/foundation.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/prepa/concours/data/models/session_model.dart';
import 'package:monprof/prepa/concours/data/repository/concours_repository.dart';

class SessionDetailController extends ChangeNotifier {
  final ConcoursRepository repository;
  final String sessionId;

  SessionDetailController({
    required this.repository,
    required this.sessionId,
  });

  AppState<SessionModel> state = AppState();

  Future<void> load() async {
    state = AppState(status: AppStatus.loading);
    notifyListeners();
    state = await repository.getSessionById(sessionId);
    notifyListeners();
  }

  Future<void> refresh() => load();
}
