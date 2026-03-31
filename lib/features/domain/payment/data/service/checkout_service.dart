// features/checkout/data/service/checkout_service.dart

import 'package:agrilink/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class CheckoutService {
  final DioClient dioClient;

  CheckoutService(this.dioClient);

  Future<Response> processCheckout() async {
    final response = await dioClient.post(
      '/orders/checkout',
      data: {}, // Empty body as per your API
    );
    return response;
  }
}