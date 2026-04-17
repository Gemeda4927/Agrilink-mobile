// lib/features/order/data/models/farmer_product_model.dart

import '../../domain/entities/farmer_product.dart';

class FarmerProductModel extends FarmerProduct {
  FarmerProductModel({
    required super.id,
    required super.farmerId,
    required super.name,
    required super.subCategoryId,
    required super.amount,
    required super.price,
    required super.description,
    super.image,
    required super.createdAt,
  });

  factory FarmerProductModel.fromJson(Map<String, dynamic> json) {
    return FarmerProductModel(
      id: json['id'] as String? ?? '',
      farmerId: json['farmerId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      subCategoryId: json['subCategoryId'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      price: json['price']?.toString() ?? '0',
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }
}