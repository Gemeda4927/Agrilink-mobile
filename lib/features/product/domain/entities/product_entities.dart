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

  // Additional fields from API
  final String? city;
  final bool? withDelivery;

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

  // Farmer coordinates (from profile)
  final String? farmerLatitude;
  final String? farmerLongitude;

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
    this.city,
    this.withDelivery,
    this.subCategoryName,
    this.categoryId,
    this.categoryName,
    this.farmerEmail,
    this.farmerPhone,
    this.farmerRole,
    this.farmerFullName,
    this.farmerImageUrl,
    this.farmerLatitude,
    this.farmerLongitude,
    this.kebeleName,
    this.woredaName,
    this.zoneName,
    this.regionName,
  });

  // Computed properties
  bool get isAvailable => amount > 0;

  String get formattedPrice {
    try {
      final priceNum = double.parse(price);
      if (priceNum >= 1000000) {
        return '${(priceNum / 1000000).toStringAsFixed(1)}M Br';
      } else if (priceNum >= 1000) {
        return '${(priceNum / 1000).toStringAsFixed(1)}K Br';
      }
      return '${priceNum.toStringAsFixed(0)} Br';
    } catch (e) {
      return '$price Br';
    }
  }

  String get formattedAmount {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  // Helper method to get farmer coordinates as doubles
  (double?, double?) getCoordinates() {
    double? lat;
    double? lng;

    if (farmerLatitude != null && farmerLatitude!.isNotEmpty) {
      lat = double.tryParse(farmerLatitude!);
    }
    if (farmerLongitude != null && farmerLongitude!.isNotEmpty) {
      lng = double.tryParse(farmerLongitude!);
    }

    return (lat, lng);
  }

  // Helper method to check if farmer has valid coordinates
  bool get hasValidCoordinates {
    final (lat, lng) = getCoordinates();
    return lat != null && lng != null && lat != 0 && lng != 0;
  }

  // Helper method to get formatted location string
  String getFormattedLocation() {
    final parts = <String>[];

    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (kebeleName != null && kebeleName!.isNotEmpty) parts.add(kebeleName!);
    if (woredaName != null && woredaName!.isNotEmpty) parts.add(woredaName!);
    if (zoneName != null && zoneName!.isNotEmpty) parts.add(zoneName!);
    if (regionName != null && regionName!.isNotEmpty) parts.add(regionName!);

    if (parts.isEmpty) return 'Location not specified';
    return parts.join(', ');
  }

  // Helper method to get farmer display name
  String getFarmerDisplayName() {
    if (farmerFullName != null && farmerFullName!.isNotEmpty) {
      return farmerFullName!;
    } else if (farmerEmail != null && farmerEmail!.isNotEmpty) {
      return farmerEmail!.split('@').first;
    }
    return 'Farmer';
  }

  // Helper method to get category display name
  String getCategoryDisplay() {
    if (categoryName != null && categoryName!.isNotEmpty) {
      return categoryName!;
    } else if (subCategoryName != null && subCategoryName!.isNotEmpty) {
      return subCategoryName!;
    }
    return 'Product';
  }

  // Helper method to check if product has image
  bool get hasImage => image.isNotEmpty && image != 'null';

  // Helper method to check if farmer has image
  bool get hasFarmerImage =>
      farmerImageUrl != null &&
      farmerImageUrl!.isNotEmpty &&
      farmerImageUrl != 'null';

  // Copy with method for updates
  ProductEntity copyWith({
    String? id,
    String? farmerId,
    String? name,
    String? subCategoryId,
    int? amount,
    String? price,
    String? description,
    String? image,
    DateTime? createdAt,
    String? city,
    bool? withDelivery,
    String? subCategoryName,
    String? categoryId,
    String? categoryName,
    String? farmerEmail,
    String? farmerPhone,
    String? farmerRole,
    String? farmerFullName,
    String? farmerImageUrl,
    String? farmerLatitude,
    String? farmerLongitude,
    String? kebeleName,
    String? woredaName,
    String? zoneName,
    String? regionName,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      city: city ?? this.city,
      withDelivery: withDelivery ?? this.withDelivery,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      farmerEmail: farmerEmail ?? this.farmerEmail,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      farmerRole: farmerRole ?? this.farmerRole,
      farmerFullName: farmerFullName ?? this.farmerFullName,
      farmerImageUrl: farmerImageUrl ?? this.farmerImageUrl,
      farmerLatitude: farmerLatitude ?? this.farmerLatitude,
      farmerLongitude: farmerLongitude ?? this.farmerLongitude,
      kebeleName: kebeleName ?? this.kebeleName,
      woredaName: woredaName ?? this.woredaName,
      zoneName: zoneName ?? this.zoneName,
      regionName: regionName ?? this.regionName,
    );
  }

  @override
  String toString() {
    return 'ProductEntity(id: $id, name: $name, amount: $amount, price: $price, hasValidCoordinates: $hasValidCoordinates)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
