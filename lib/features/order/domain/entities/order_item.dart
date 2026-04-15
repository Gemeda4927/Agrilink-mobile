class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int amount;
  final double priceAtOrder;
  final Product product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.amount,
    required this.priceAtOrder,
    required this.product,
  });

  double get subtotal => amount * priceAtOrder;
  String get formattedSubtotal => '${subtotal.toStringAsFixed(0)} ETB';
}

class Product {
  final String id;
  final String farmerId;
  final String name;
  final String subCategoryId;
  final int amount;
  final double price;
  final String description;
  final String image;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.subCategoryId,
    required this.amount,
    required this.price,
    required this.description,
    required this.image,
    required this.createdAt,
  });
  
  String get formattedPrice => '${price.toStringAsFixed(0)} ETB';
}