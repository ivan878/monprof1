import 'package:dio/dio.dart';

class SubscriptionService {
  final Dio dio;
  SubscriptionService({required this.dio});

  // ── Payment Services ─────────────────────────────────────────────────────────

  /// GET /payment-services
  Future<List<dynamic>> listPaymentServices() async {
    final res = await dio.get('/payment-services');
    final data = res.data['data'];
    if (data is List) return data;
    if (data is Map && data['content'] is List) return data['content'] as List;
    return [];
  }

  /// GET /payment-services/{id}
  Future<Map<String, dynamic>> getPaymentServiceById(String id) async {
    final res = await dio.get('/payment-services/$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /payment-services/sens/DEBIT
  Future<List<dynamic>> listPaymentServicesBySens(String sens) async {
    final res = await dio.get('/payment-services/sens/$sens');
    final data = res.data['data'];
    if (data is List) return data;
    if (data is Map && data['content'] is List) return data['content'] as List;
    return [];
  }

  // ── Subscriptions ────────────────────────────────────────────────────────────

  /// POST /subscriptions body: { concoursSessionId, paymentServiceId, phoneNumber, count: 1 }
  Future<Map<String, dynamic>> createSubscription({
    required String concoursSessionId,
    required String paymentServiceId,
    required String phoneNumber,
    int count = 1,
  }) async {
    final res = await dio.post('/subscriptions', data: {
      'concoursSessionId': concoursSessionId,
      'paymentServiceId': paymentServiceId,
      'phoneNumber': phoneNumber,
      'count': count,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /subscriptions/{id}
  Future<Map<String, dynamic>> getSubscriptionById(String id) async {
    final res = await dio.get('/subscriptions/$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /subscriptions/me?page=0&size=10
  Future<Map<String, dynamic>> listMySubscriptions({
    int page = 0,
    int size = 10,
  }) async {
    final res = await dio.get('/subscriptions/me', queryParameters: {
      'page': page,
      'size': size,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /subscriptions/me/status/{status}?page=0&size=10
  Future<Map<String, dynamic>> listMySubscriptionsByStatus(
    String status, {
    int page = 0,
    int size = 10,
  }) async {
    final res = await dio.get(
      '/subscriptions/me/status/$status',
      queryParameters: {'page': page, 'size': size},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /subscriptions/me/session/{sessionId}
  /// Retourne la souscription de l'utilisateur pour cette session (ou null dans data si aucune).
  Future<Map<String, dynamic>?> getMySubscriptionBySession(String sessionId) async {
    final res = await dio.get('/subscriptions/me/session/$sessionId');
    final data = res.data['data'];
    if (data == null) return null;
    return data as Map<String, dynamic>;
  }

  /// DELETE /subscriptions/{id}
  Future<void> deleteSubscription(String id) async {
    await dio.delete('/subscriptions/$id');
  }

  // ── Codes de souscription ────────────────────────────────────────────────────

  /// GET /subscription-codes/me — codes achetés, regroupés par session de concours.
  Future<List<dynamic>> listMyCodeGroups() async {
    final res = await dio.get('/subscription-codes/me');
    final data = res.data['data'];
    if (data is List) return data;
    return [];
  }

  /// POST /subscription-codes/activate — consomme un code au profit de l'utilisateur.
  /// [concoursSessionId] : session attendue. Renseignée depuis la page d'un
  /// concours, elle fait rejeter un code acheté pour un autre concours —
  /// sans le consommer. Omise, le code active le concours pour lequel il a été acheté.
  Future<Map<String, dynamic>> activateCode(
    String code, {
    String? concoursSessionId,
  }) async {
    final res = await dio.post(
      '/subscription-codes/activate',
      data: {
        'code': code,
        if (concoursSessionId != null) 'concoursSessionId': concoursSessionId,
      },
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Transactions ─────────────────────────────────────────────────────────────

  /// GET /transactions/{id}
  Future<Map<String, dynamic>> getTransactionById(String id) async {
    final res = await dio.get('/transactions/$id');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// GET /transactions/me?page=0&size=10
  Future<Map<String, dynamic>> listMyTransactions({
    int page = 0,
    int size = 10,
  }) async {
    final res = await dio.get('/transactions/me', queryParameters: {
      'page': page,
      'size': size,
    });
    return res.data['data'] as Map<String, dynamic>;
  }
}
