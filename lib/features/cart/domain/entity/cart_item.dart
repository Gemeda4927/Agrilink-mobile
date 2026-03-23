import 'package:agrilink/features/product/domain/entities/product_entities.dart';

class CartItem {
  final String id;
  final String productId;
  final int amount;
  final ProductEntity product;

  const CartItem({
    required this.id,
    required this.productId,
    required this.amount,
    required this.product,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    int? amount,
    ProductEntity? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      amount: amount ?? this.amount,
      product: product ?? this.product,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.productId == productId &&
        other.amount == amount &&
        other.product == product;
  }

  @override
  int get hashCode => Object.hash(id, productId, amount, product);

  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, amount: $amount, product: ${product.name})';
  }
}
