import 'package:monprof/cours/data/models/cours_model.dart';
import 'package:monprof/cours/data/services/cours_service.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first

class CoursRepository {
  final CoursService service;
  CoursRepository({
    required this.service,
  });

  Future<List<Cours>> getCours(
      {int page = 1, required int categorie, required int matiere}) async {
    final response = await service.getCours(
        page: page, categorie: categorie, matiere: matiere);
    if (response['status']) {
      final List coursmap = response['data']['data'];
      final List<Cours> courList =
          coursmap.map((json) => Cours.fromMap(json)).toList();
      return courList;
    } else {
      throw Exception(response['error']);
    }
  }

  ///
}
