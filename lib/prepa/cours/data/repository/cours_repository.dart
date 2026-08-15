import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/prepa/common/models/prepa_page.dart';
import 'package:monprof/prepa/cours/data/models/cours_model.dart';
import 'package:monprof/prepa/cours/data/models/matiere_model.dart';
import 'package:monprof/prepa/cours/data/services/cours_service.dart';

class PrepaCoursRepository {
  final PrepaCoursService service;
  const PrepaCoursRepository({required this.service});

  Future<AppState<PrepaPage<MatiereModel>>> listMatieres({
    int page = 1,
    int size = 25,
  }) async {
    try {
      final data = await service.listMatieres(page: page, size: size);
      final page0 = PrepaPage.fromJson(data, MatiereModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<MatiereModel>> getMatiereById(String id) async {
    try {
      final data = await service.getMatiereById(id);
      return AppState(status: AppStatus.data, data: MatiereModel.fromJson(data));
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaPage<PrepaCoursModel>>> listCours({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final data = await service.listCours(page: page, size: size);
      final page0 = PrepaPage.fromJson(data, PrepaCoursModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaCoursModel>> getCoursById(String id) async {
    try {
      final data = await service.getCoursById(id);
      return AppState(status: AppStatus.data, data: PrepaCoursModel.fromJson(data));
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }

  Future<AppState<PrepaPage<PrepaCoursModel>>> getCoursByMatiereId(
    String matiereId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final data = await service.getCoursByMatiereId(
        matiereId,
        page: page,
        size: size,
      );
      final page0 = PrepaPage.fromJson(data, PrepaCoursModel.fromJson);
      return AppState(status: AppStatus.data, data: page0);
    } catch (e) {
      return AppState(status: AppStatus.error, errorModel: returnError(e));
    }
  }
}
