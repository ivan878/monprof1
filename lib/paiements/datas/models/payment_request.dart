class PaymentRequest {
  final String payerPhoneNumber;
  final String beneficiaryPhoneNumber;
  final int quantity;
  final int categoryId;
  final int paymentServiceId;

  const PaymentRequest({
    required this.payerPhoneNumber,
    required this.beneficiaryPhoneNumber,
    required this.quantity,
    required this.categoryId,
    required this.paymentServiceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'numero_payeur': payerPhoneNumber,
      'numero_client': beneficiaryPhoneNumber,
      'nombre_de_code': quantity,
      'categorie_id': categoryId,
      'payment_service_id': paymentServiceId,
      'sens': 'IN',
    };
  }
}
