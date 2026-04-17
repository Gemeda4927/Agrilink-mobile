class FarmerProduct {
  final String id;
  final String farmerId;
  final String name;
  final String subCategoryId;
  final int amount;
  final String price;
  final String description;
  final String? image;
  final DateTime createdAt;

  FarmerProduct({
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

  bool get hasImage => image != null && image!.isNotEmpty;
  String get imageUrl => image ?? '';
  int get parsedPrice => int.tryParse(price) ?? 0;
  String get formattedPrice => '$parsedPrice ETB';
}
