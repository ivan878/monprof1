enum PaymentFlowStatus { idle, creating, pending, success, failed }

class PaymentTransaction {
  final int id;
  final String? reference;
  final String status;
  final bool isFinal;
  final bool isSuccessful;
  final String? failureReason;
  final int? paymentId;
  final double? baseAmount;
  final double? serviceFee;
  final double? amount;
  final String? conclusionMethod;

  const PaymentTransaction({
    required this.id,
    required this.status,
    required this.isFinal,
    required this.isSuccessful,
    this.reference,
    this.failureReason,
    this.paymentId,
    this.baseAmount,
    this.serviceFee,
    this.amount,
    this.conclusionMethod,
  });

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) {
    final status = map['status']?.toString().toUpperCase() ?? 'PENDING';
    final successful = map.containsKey('is_successful')
        ? map['is_successful'] == true
        : status == 'SUCCESS';
    final failed = status == 'FAILED' || status == 'CANCELLED';
    final isFinal = map.containsKey('is_final')
        ? map['is_final'] == true
        : successful || failed || status == 'ERROR';

    return PaymentTransaction(
      id: (map['id'] as num).toInt(),
      reference: map['reference']?.toString(),
      status: status,
      isFinal: isFinal,
      isSuccessful: successful,
      failureReason: map['failure_reason']?.toString(),
      paymentId:
          map['payment_id'] == null ? null : (map['payment_id'] as num).toInt(),
      baseAmount: _toDouble(map['base_amount']),
      serviceFee: _toDouble(map['service_fee']),
      amount: _toDouble(map['amount']),
      conclusionMethod: map['conclusion_method']?.toString(),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
