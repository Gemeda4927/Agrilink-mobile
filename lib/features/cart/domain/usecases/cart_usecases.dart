// features/cart/domain/usecases/cart_usecases.dart

import 'package:agrilink/features/cart/domain/entity/cart_item.dart';
import 'package:agrilink/features/cart/domain/repositories/cart_repository.dart';

// ============================================================================
// Get Cart Use Case
// ============================================================================

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<List<CartItem>> call() async {
    return await repository.getCart();
  }
}

// ============================================================================
// Add to Cart Use Case
// ============================================================================

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<CartItem> call({
    required String productId,
    required int amount,
  }) async {
    // Validation
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    return await repository.addToCart(productId, amount);
  }
}

// ============================================================================
// Update Cart Use Case
// ============================================================================

class UpdateCartUseCase {
  final CartRepository repository;

  UpdateCartUseCase(this.repository);

  Future<CartItem> call({
    required String productId,
    required int amount,
  }) async {
    // Validation
    if (amount < 0) {
      throw Exception('Amount cannot be negative');
    }

    if (amount == 0) {
      throw Exception('Use remove item to delete item from cart');
    }

    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }

    return await repository.updateCart(productId, amount);
  }
}

// ============================================================================
// Remove from Cart Use Case
// ============================================================================

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
