import 'package:monprof/home/data/models/categorie_model.dart';
import 'package:monprof/home/data/models/matieres_models.dart';
import 'package:monprof/home/data/services/home_services.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class HomeRepository {
  HomeService service;
  HomeRepository({
    required this.service,
  });

  Future<List<Matiere>> getMatieres() async {
    try {
      final data = await service.getMatieres();
      final listeMatieres = List<Matiere>.from(
        (data['data'] as List).map((json) => Matiere.fromJson(json)).toList(),
      );
      return listeMatieres;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Categorie>> getCategorie() async {
    try {
      final data = await service.getCategorie();
      final listeMatieres = List<Categorie>.from(
        (data['data'] as List).map((json) => Categorie.fromJson(json)).toList(),
      );
      return listeMatieres;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CategorieStatus>> getCategorieStatus() async {
    try {
      final data = await service.getCategorieStatus();
      final listeMatieres = List<CategorieStatus>.from(
        (data['data'] as List)
            .map((json) => CategorieStatus.fromJson(json))
            .toList(),
      );
      return listeMatieres;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CategorieParentStatus>> getCategoriePrentStatus() async {
    try {
      final data = await service.getCategoriePrentStatus();
      final listeCategorie = List<CategorieParentStatus>.from(
        (data['data'] as List)
            .map((json) => CategorieParentStatus.fromMap(json))
            .toList(),
      );
      return listeCategorie;
    } catch (e) {
      rethrow;
    }
  }
}
