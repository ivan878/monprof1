import 'package:dio/dio.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/paiements/datas/models/paiements.dart';

class PaiementServices {
  final Dio dio;

  PaiementServices(this.dio);

  Future<Map<String, dynamic>> requestPaiements(Paiements paiement) async {
    final hearder = await header();
    try {
      final response = await dio.post(
        'paiement',
        data: paiement.toMap(),
        options: Options(headers: hearder),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> activeCode(String code) async {
    final hearder = await header();
    try {
      final response = await dio.put(
        'code/active',
        data: {'code': code},
        options: Options(headers: hearder),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
