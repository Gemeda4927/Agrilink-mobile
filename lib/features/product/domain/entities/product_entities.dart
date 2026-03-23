class ProductEntity {
  final String id;
  final String farmerId;
  final String name;
  final String subCategoryId;
  final int amount;
  final String price;
  final String description;
  final String image;
  final DateTime createdAt;

  final String? subCategoryName;
  final String? categoryId;

  final String? farmerEmail;
  final String? farmerPhone;
  final String? farmerRole;

  ProductEntity({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.subCategoryId,
    required this.amount,
    required this.price,
    required this.description,
    required this.image,
    required this.createdAt,

    this.subCategoryName,
    this.categoryId,
    this.farmerEmail,
    this.farmerPhone,
    this.farmerRole,
  });
}