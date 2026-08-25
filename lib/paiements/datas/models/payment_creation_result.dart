import 'package:monprof/paiements/datas/models/payment_transaction.dart';

class PaymentCreationResult {
  final int paymentId;
  final PaymentTransaction transaction;

  const PaymentCreationResult({
    required this.paymentId,
    required this.transaction,
  });

  factory PaymentCreationResult.fromMap(Map<String, dynamic> map) {
    final payment = map['data'] as Map<String, dynamic>? ?? const {};
    final transaction = map['transaction'] as Map<String, dynamic>? ?? const {};

    return PaymentCreationResult(
      paymentId: (payment['id'] as num).toInt(),
      transaction: PaymentTransaction.fromMap({
        ...transaction,
        'payment_id': payment['id'],
      }),
    );
  }
}
