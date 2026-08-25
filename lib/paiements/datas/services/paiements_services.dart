import 'package:dio/dio.dart';
import 'package:monprof/corps/api_service.dart';
import 'package:monprof/paiements/datas/models/payment_request.dart';
import 'package:monprof/paiements/datas/models/payment_service.dart';

class PaiementServices {
  final Dio dio;

  PaiementServices(this.dio);

  Future<Map<String, dynamic>> createPayment(PaymentRequest payment) async {
    final headers = await header();
    final response = await dio.post(
      'paiement',
      data: payment.toMap(),
      options: Options(headers: headers),
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> activeCode(String code) async {
    final headers = await header();
    try {
      final response = await dio.put(
        'code/active',
        data: {'code': code},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PaymentService>> getPaymentServices() async {
    final headers = await header();
    final response = await dio.get(
      'payment_services',
      queryParameters: const {'sens': 'IN'},
      options: Options(headers: headers),
    );

    return (response.data['data'] as List)
        .map((item) => PaymentService.fromMap(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Future<Map<String, dynamic>> getTransactionStatus(
    int transactionId,
  ) async {
    final headers = await header();
    final response = await dio.get(
      'transactions/$transactionId/status',
      options: Options(headers: headers),
    );

    return Map<String, dynamic>.from(response.data as Map);
  }
}
