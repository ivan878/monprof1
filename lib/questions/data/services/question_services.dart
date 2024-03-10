import 'dart:io';

import 'package:dio/dio.dart';
import 'package:monprof/corps/api_service.dart' as corps;
import 'package:monprof/questions/data/models/question.dart';

class QuestionService {
  final Dio dio;
  QuestionService({required this.dio});

  Future<Map<String, dynamic>> getQuestion(
      {required int categorie, required int matiere}) async {
    final header = await corps.header();
    final reponse = await dio.get(
      '/question',
      options: Options(headers: header),
      queryParameters: {
        'categorie_id': categorie,
        'matiere_id': matiere,
      },
    );
    return reponse.data;
  }

//poser une question

  Future<Map<String, dynamic>> createQuestion(
      {required Questions question, File? image}) async {
    final header = await corps.header();
    final data = FormData.fromMap({
      ...question.toMap(),
      if (image != null) 'image': await MultipartFile.fromFile(image.path)
    });
    final reponse = await dio.post('/question',
        options: Options(headers: header), data: data);
    return reponse.data;
  }

  ///
}
