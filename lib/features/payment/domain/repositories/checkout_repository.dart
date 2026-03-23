// features/checkout/domain/repositories/checkout_repository.dart

class CheckoutResponseModel {
  final String orderId;
  final String paymentUrl;

  CheckoutResponseModel({
    required this.orderId,
    required this.paymentUrl,
  });

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResponseModel(
      orderId: json['orderId'],
      paymentUrl: json['paymentUrl'],
    );
  }
}

abstract class CheckoutRepository {
  Future<CheckoutResponseModel> processCheckout();
}