// lib/features/order/data/models/product_order_model.dart

import '../../domain/entities/product.dart';

class ProductOrderModel {
  final String id;
  final String farmerId;
  final String name;
  final String subCategoryId;
  final int amount;
  final double price;
  final String description;
  final String? image;
  final DateTime createdAt;

  ProductOrderModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.subCategoryId,
    required this.amount,
    required this.price,
    required this.description,
    this.image,
    required this.createdAt,
  });

  factory ProductOrderModel.fromJson(Map<String, dynamic> json) {
    return ProductOrderModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      name: json['name'] ?? '',
      subCategoryId: json['subCategoryId'] ?? '',
      amount: json['amount'] ?? 0,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      description: json['description'] ?? '',
      image: json['image'], // This can be null - key fix!
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  factory ProductOrderModel.empty() {
    return ProductOrderModel(
      id: '',
      farmerId: '',
      name: 'Unknown Product',
      subCategoryId: '',
      amount: 0,
      price: 0.0,
      description: 'No description available',
      image: null,
      createdAt: DateTime.now(),
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      farmerId: farmerId,
      name: name,
      subCategoryId: subCategoryId,
      amount: amount,
      price: price,
      description: description,
      image: image,
      createdAt: createdAt,
    );
  }

  String getImageUrl() => image ?? '';

  bool hasImage() => image != null && image!.isNotEmpty;
}
