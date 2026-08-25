import 'package:flutter_test/flutter_test.dart';
import 'package:monprof/paiements/datas/models/payment_request.dart';
import 'package:monprof/paiements/datas/models/payment_service.dart';
import 'package:monprof/paiements/datas/models/payment_transaction.dart';

void main() {
  group('PaymentService', () {
    test('selects an active incoming service using its phone pattern', () {
      final service = PaymentService.fromMap({
        'id': 9,
        'title': 'Mobile Money',
        'is_active': true,
        'sens': 'in',
        'reg_exp': r'^69[0-9]{7}$',
      });

      expect(service.acceptsPhoneNumber('690000000'), isTrue);
      expect(service.acceptsPhoneNumber('650000000'), isFalse);
      expect(service.sense, 'IN');
    });

    test('calculates the user share of provider fees and rounds up', () {
      final service = PaymentService.fromMap({
        'id': 12,
        'is_active': true,
        'sens': 'IN',
        'reg_exp': r'^6[0-9]{8}$',
        'provider_fee_percentage': '2.5',
        'user_fee_percentage': 50,
      });

      expect(service.serviceFeeFor(1500), 20);
    });

    test('rejects outgoing or inactive services', () {
      final outgoing = PaymentService.fromMap({
        'id': 10,
        'is_active': true,
        'sens': 'OUT',
        'reg_exp': r'^6[0-9]{8}$',
      });
      final inactive = PaymentService.fromMap({
        'id': 11,
        'is_active': false,
        'sens': 'IN',
        'reg_exp': r'^6[0-9]{8}$',
      });

      expect(outgoing.acceptsPhoneNumber('690000000'), isFalse);
      expect(inactive.acceptsPhoneNumber('690000000'), isFalse);
    });
  });

  test('payment request only exposes the local service contract', () {
    const request = PaymentRequest(
      payerPhoneNumber: '690000000',
      beneficiaryPhoneNumber: '691000000',
      quantity: 2,
      categoryId: 4,
      paymentServiceId: 15,
    );

    expect(request.toMap(), {
      'numero_payeur': '690000000',
      'numero_client': '691000000',
      'nombre_de_code': 2,
      'categorie_id': 4,
      'payment_service_id': 15,
      'sens': 'IN',
    });
    expect(request.toMap(), isNot(contains('subscription_id')));
    expect(request.toMap(), isNot(contains('provider')));
  });

  group('PaymentTransaction', () {
    test('keeps provider success pending until the server finalizes payment',
        () {
      final transaction = PaymentTransaction.fromMap({
        'id': 1,
        'status': 'SUCCESS',
        'is_final': false,
        'is_successful': false,
      });

      expect(transaction.isFinal, isFalse);
      expect(transaction.isSuccessful, isFalse);
    });

    test('exposes the terminal failure reason', () {
      final transaction = PaymentTransaction.fromMap({
        'id': 2,
        'status': 'FAILED',
        'is_final': true,
        'is_successful': false,
        'failure_reason': 'Solde insuffisant',
      });

      expect(transaction.isFinal, isTrue);
      expect(transaction.isSuccessful, isFalse);
      expect(transaction.failureReason, 'Solde insuffisant');
    });
  });
}
