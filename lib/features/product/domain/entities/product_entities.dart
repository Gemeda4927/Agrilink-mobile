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

  // SubCategory nested data
  final String? subCategoryName;
  final String? categoryId;
  final String? categoryName;
  
  // Farmer nested data
  final String? farmerEmail;
  final String? farmerPhone;
  final String? farmerRole;
  final String? farmerFullName;
  final String? farmerImageUrl;
  
  // Location data from farmer's profile
  final String? kebeleName;
  final String? woredaName;
  final String? zoneName;
  final String? regionName;

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
    this.categoryName,
    this.farmerEmail,
    this.farmerPhone,
    this.farmerRole,
    this.farmerFullName,
    this.farmerImageUrl,
    this.kebeleName,
    this.woredaName,
    this.zoneName,
    this.regionName,
  });
}