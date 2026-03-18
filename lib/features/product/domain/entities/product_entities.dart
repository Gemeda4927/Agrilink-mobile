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
  });
}
