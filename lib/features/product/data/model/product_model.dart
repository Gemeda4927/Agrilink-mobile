import '../../domain/entities/product_entities.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.farmerId,
    required super.name,
    required super.subCategoryId,
    required super.amount,
    required super.price,
    required super.description,
    required super.image,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      farmerId: json['farmerId'],
      name: json['name'],
      subCategoryId: json['subCategoryId'],
      amount: json['amount'],
      price: json['price'].toString(),
      description: json['description'],
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'name': name,
      'subCategoryId': subCategoryId,
      'amount': amount,
      'price': price,
      'description': description,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
