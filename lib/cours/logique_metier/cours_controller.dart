import 'package:get/get.dart';
import 'package:monprof/corps/utils/app_state.dart';
import 'package:monprof/corps/utils/error_handler.dart';
import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/data/models/matieres_models.dart';
import 'package:monprof/cours/data/repository/cours_repository.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class CoursController extends GetxController {
  final CoursRepository repository;
  final Matiere matiere;
  final Categorie categorie;
  CoursController({
    required this.repository,
    required this.categorie,
    required this.matiere,
  });

  AppState<List<Cours>?> coursState =
      AppState<List<Cours>?>(status: AppStatus.loading);

  @override
  void onInit() {
    getCours();
    update();
    super.onInit();
  }

  Future getCours() async {
    try {
      coursState = AppState<List<Cours>?>(status: AppStatus.loading);
      update();
      final cours = await repository.getCours(
          categorie: categorie.id!, matiere: matiere.id!);
      coursState = AppState<List<Cours>?>(status: AppStatus.data, data: cours);
      update();
    } catch (e) {
      coursState = AppState(
        status: AppStatus.error,
        data: null,
        errorModel: returnError(e),
      );
      update();
    }
  }
}
