import 'dart:io';

import 'package:monprof/corps/utils/helper.dart';
import 'package:monprof/questions/data/models/question.dart';
import 'package:monprof/questions/data/services/question_services.dart';

class QuestionRepository {
  final QuestionService service;

  QuestionRepository(this.service);

  Future<List<Questions>> getQuestion(
      {required int categorie, required int matiere}) async {
    final data =
        await service.getQuestion(categorie: categorie, matiere: matiere);
    loger(data['data']);
    final results = (data['data']['data'] as List)
        .map((map) => Questions.fromMap(map))
        .toList();
    return results;
  }

  Future<bool> createQuestion(
      {required Questions question, File? image}) async {
    final data = await service.createQuestion(question: question, image: image);
    return data['status'] as bool;
  }

  ///
}
