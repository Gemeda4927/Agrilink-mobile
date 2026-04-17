
class Product {
  final String id;
  final String farmerId;
  final String name;
  final String subCategoryId;
  final int amount;
  final double price;
  final String description;
  final String? image; // Made nullable - this is the key fix!
  final DateTime createdAt;

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.subCategoryId,
    required this.amount,
    required this.price,
    required this.description,
    this.image, // Now optional
    required this.createdAt,
  });
  
  String get formattedPrice => '${price.toStringAsFixed(0)} ETB';
  
  // Helper method to check if image exists
  bool get hasImage => image != null && image!.isNotEmpty;
  
  // Helper method to get image URL with fallback
  String get imageUrl => image ?? '';
  
  // Helper method to get product display name
  String get displayName => name.isNotEmpty ? name : 'Unknown Product';
}