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
        'categorie_id':categorie,
        'matiere_id':matiere,
      },
    );
    return reponse.data;
  }

//poser une question 

Future<Map<String,dynamic>>createQuestion({required Questions question})async{
final header = await corps.header();
    final reponse = await dio.post(
      '/question',
      options: Options(headers: header),
      data: question.toMap()
    );
    return reponse.data;
}

  ///
}
