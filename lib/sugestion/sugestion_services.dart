import 'package:dio/dio.dart';
import 'package:monprof/corps/api_service.dart';

class SugestionServices {
  Future sendSugeestion(String suggestionBody) async {
    final dio = API().dio;
    final herders = await header();
    try {
      final response = await dio.post('/sugestion',
          data: {'body': suggestionBody},
          options: Options(
            headers: herders,
          ));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
