// features/checkout/domain/usecases/checkout_usecase.dart

import 'package:agrilink/features/domain/payment/domain/repositories/checkout_repository.dart';

// ============================================================================
// Process Checkout Use Case
// ============================================================================

class ProcessCheckoutUseCase {
  final CheckoutRepository repository;

  ProcessCheckoutUseCase(this.repository);

  Future<CheckoutResponseModel> execute() async {
    return await repository.processCheckout();
  }
}
