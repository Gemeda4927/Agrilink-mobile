import '../../domain/entities/order_item.dart';

class ProductModel {
  final String id;
  final String farmerId;
  final String name;
  final String subCategoryId;
  final int amount;
  final double price;
  final String description;
  final String image;
  final DateTime createdAt;

  ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      farmerId: json['farmerId'],
      name: json['name'],
      subCategoryId: json['subCategoryId'],
      amount: json['amount'],
      price: _parsePrice(json['price']),
      description: json['description'],
      image: json['image'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is String) return double.parse(price);
    if (price is num) return price.toDouble();
    return 0.0;
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
}
