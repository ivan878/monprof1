import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/concours/data/models/concours_model.dart';
import 'package:monprof/prepa/concours/data/models/session_model.dart';
import 'package:monprof/prepa/concours/data/services/concours_service.dart';

class ConcoursRepository {
  final ConcoursService service;
  const ConcoursRepository({required this.service});

  Future<AppState<PrepaPage<ConcoursModel>>> listConcours({
    int page = 1,
    int size = 20,
  }) async {
    try {
      final data = await service.listConcours(page: page, size: size);
      final page0 = PrepaPage.fromJson(data, ConcoursModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<ConcoursModel>> getConcoursById(String id) async {
    try {
      final data = await service.getConcoursById(id);
      return AppState(
          status: AppStatus.data, data: ConcoursModel.fromJson(data));
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaPage<SessionModel>>> listSessions({
    int page = 1,
    int size = 25,
  }) async {
    try {
      final data = await service.listSessions(page: page, size: size);
      final page0 = PrepaPage.fromJson(data, SessionModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<SessionModel>> getSessionById(String id) async {
    try {
      final data = await service.getSessionById(id);
      return AppState(
          status: AppStatus.data, data: SessionModel.fromJson(data));
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaPage<SessionModel>>> getSessionsByConcoursId(
    String concoursId, {
    int page = 1,
    int size = 25,
  }) async {
    try {
      final data = await service.getSessionsByConcoursId(
        concoursId,
        page: page,
        size: size,
      );
      final page0 = PrepaPage.fromJson(data, SessionModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }
}
