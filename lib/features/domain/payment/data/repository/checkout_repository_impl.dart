import 'package:agrilink/features/domain/payment/data/service/checkout_service.dart';
import 'package:agrilink/features/domain/payment/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutService checkoutService;

  CheckoutRepositoryImpl(this.checkoutService);

  @override
  Future<CheckoutResponseModel> processCheckout() async {
    try {
      final response = await checkoutService.processCheckout();

      if (response.statusCode == 201) {
        return CheckoutResponseModel.fromJson(response.data);
      } else {
        throw Exception('Checkout failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to process checkout: $e');
    }
  }
}
