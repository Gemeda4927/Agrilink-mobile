// features/cart/domain/usecases/cart_usecases.dart

import 'package:agrilink/features/cart/domain/entity/cart_item.dart';
import 'package:agrilink/features/cart/domain/repositories/cart_repository.dart';

// ============================================================================
// CART USE CASES
// ============================================================================

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<List<CartItem>> call() async {
    return await repository.getCart();
  }
}

// ----------------------------------------------------------------------------

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<CartItem> call({
    required String productId,
    required int amount,
  }) async {
    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    return await repository.addToCart(productId, amount);
  }
}

// ----------------------------------------------------------------------------

class UpdateCartUseCase {
  final CartRepository repository;

  UpdateCartUseCase(this.repository);

  Future<CartItem> call({
    required String productId,
    required int amount,
  }) async {
    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    return await repository.updateCart(productId, amount);
  }
}

// ----------------------------------------------------------------------------

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<void> call(String productId) async {
    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    return await repository.removeItem(productId);
  }
}

// ----------------------------------------------------------------------------

class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<void> call(List<String> productIds) async {
    if (productIds.isEmpty) {
      throw Exception('Cart is already empty');
    }

    return await repository.clearCart(productIds);
  }
}

// ----------------------------------------------------------------------------

class GetCartTotalUseCase {
  final CartRepository repository;

  GetCartTotalUseCase(this.repository);

  Future<double> call() async {
    return await repository.getCartTotal();
  }
}

// ============================================================================
// PAYMENT USE CASES
// ============================================================================

// features/cart/domain/usecases/cart_usecases.dart

class CheckoutUseCase {
  final CartRepository repository;

  CheckoutUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String address,
    required String paymentMethod,
    String? phone,
  }) async {
    if (address.isEmpty) {
      throw Exception('Address is required');
    }

    if (paymentMethod.isEmpty) {
      throw Exception('Payment method is required');
    }

    return await repository.checkout(
      address: address,
      paymentMethod: paymentMethod,
      phone: phone,
    );
  }
}

class VerifyPaymentUseCase {
  final CartRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<Map<String, dynamic>> call(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID is required');
    }

    return await repository.verifyPayment(orderId);
  }
}

// ----------------------------------------------------------------------------

class CheckPaymentStatusUseCase {
  final CartRepository repository;

  CheckPaymentStatusUseCase(this.repository);

  Future<Map<String, dynamic>> call(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID is required');
    }

    return await repository.checkPaymentStatus(orderId);
  }
}

// ----------------------------------------------------------------------------

class CancelOrderUseCase {
  final CartRepository repository;

  CancelOrderUseCase(this.repository);

  Future<void> call(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID is required');
    }

    return await repository.cancelOrder(orderId);
  }
}

// ----------------------------------------------------------------------------

class GetMyOrdersUseCases {
  final CartRepository repository;

  GetMyOrdersUseCases(this.repository);

  Future<List<dynamic>> call() async {
    return await repository.getMyOrders();
  }
}

// ----------------------------------------------------------------------------

class GetOrderDetailsUseCase {
  final CartRepository repository;

  GetOrderDetailsUseCase(this.repository);

  Future<Map<String, dynamic>> call(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Order ID is required');
    }

    return await repository.getOrderDetails(orderId);
  }
}
