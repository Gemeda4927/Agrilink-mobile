import 'package:agrilink/features/product/data/model/product_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final int amount;
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.amount,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      productId: json['productId'],
      amount: json['amount'],
      product: ProductModel.fromJson(json['product']),
    );
  }
}
