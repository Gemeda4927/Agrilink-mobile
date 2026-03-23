import '../../domain/entities/product_entities.dart';

class ProductModel extends ProductEntity {
  final String? subCategoryName;
  final String? categoryId;

  final String? farmerEmail;
  final String? farmerPhone;
  final String? farmerRole;

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

    this.subCategoryName,
    this.categoryId,
    this.farmerEmail,
    this.farmerPhone,
    this.farmerRole,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      farmerId: json['farmerId'],
      name: json['name'],
      subCategoryId: json['subCategoryId'],
      amount: json['amount'] ?? 0,

      // safer parsing
      price: json['price']?.toString() ?? '0',

      description: json['description'] ?? '',
      image: json['image'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),

      // ✅ nested subCategory
      subCategoryName: json['subCategory']?['name'],
      categoryId: json['subCategory']?['categoryId'],

      // ✅ nested farmer
      farmerEmail: json['farmer']?['email'],
      farmerPhone: json['farmer']?['phone'],
      farmerRole: json['farmer']?['role'],
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

      // optional (only if needed when sending)
      'subCategoryName': subCategoryName,
      'categoryId': categoryId,
      'farmerEmail': farmerEmail,
      'farmerPhone': farmerPhone,
      'farmerRole': farmerRole,
    };
  }
}