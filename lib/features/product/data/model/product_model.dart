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
    super.subCategoryName,
    super.categoryId,
    super.categoryName,
    super.farmerEmail,
    super.farmerPhone,
    super.farmerRole,
    super.farmerFullName,
    super.farmerImageUrl,
    super.kebeleName,
    super.woredaName,
    super.zoneName,
    super.regionName,
    this.city,
    this.withDelivery,
    this.farmerLatitude,
    this.farmerLongitude,
  });

  // Additional fields from the response
  final String? city;
  final bool? withDelivery;
  final String? farmerLatitude;
  final String? farmerLongitude;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Safely extract nested subCategory data
    final subCategory = json['subCategory'] as Map<String, dynamic>?;
    final category = subCategory?['category'] as Map<String, dynamic>?;

    // Safely extract nested farmer data
    final farmer = json['farmer'] as Map<String, dynamic>?;
    final profile = farmer?['profile'] as Map<String, dynamic>?;
    final kebele = profile?['kebele'] as Map<String, dynamic>?;
    final woreda = kebele?['woreda'] as Map<String, dynamic>?;
    final zone = woreda?['zone'] as Map<String, dynamic>?;
    final region = zone?['region'] as Map<String, dynamic>?;

    return ProductModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      name: json['name'] ?? '',
      subCategoryId: json['subCategoryId'] ?? '',
      amount: json['amount'] ?? 0,
      price: json['price']?.toString() ?? '0',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      city: json['city'],
      withDelivery: json['withDelivery'] ?? false,
      farmerLatitude: profile?['latitude']?.toString(),
      farmerLongitude: profile?['longitude']?.toString(),
      
      // SubCategory data
      subCategoryName: subCategory?['name'],
      categoryId: subCategory?['categoryId'],
      categoryName: category?['name'],

      // Farmer basic data
      farmerEmail: farmer?['email'],
      farmerPhone: farmer?['phone'],
      farmerRole: farmer?['role'],

      // Farmer profile data
      farmerFullName: profile?['fullName'],
      farmerImageUrl: profile?['imageUrl'],

      // Location data
      kebeleName: kebele?['name'],
      woredaName: woreda?['name'],
      zoneName: zone?['name'],
      regionName: region?['name'],
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
      'city': city,
      'withDelivery': withDelivery,
      'subCategoryName': subCategoryName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'farmerEmail': farmerEmail,
      'farmerPhone': farmerPhone,
      'farmerRole': farmerRole,
      'farmerFullName': farmerFullName,
      'farmerImageUrl': farmerImageUrl,
      'farmerLatitude': farmerLatitude,
      'farmerLongitude': farmerLongitude,
      'kebeleName': kebeleName,
      'woredaName': woredaName,
      'zoneName': zoneName,
      'regionName': regionName,
    };
  }

  // Helper method to check if product is available
  bool get isAvailable => amount > 0;

  // Helper method to get formatted location string
  String getFormattedLocation() {
    if (kebeleName != null && woredaName != null && regionName != null) {
      return '$kebeleName, $woredaName, $regionName';
    } else if (woredaName != null && regionName != null) {
      return '$woredaName, $regionName';
    } else if (regionName != null) {
      return regionName!;
    }
    return 'Location not specified';
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

  // Helper method to get farmer coordinates as doubles
  (double?, double?) getFarmerCoordinates() {
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
    final (lat, lng) = getFarmerCoordinates();
    return lat != null && lng != null && lat != 0 && lng != 0;
  }

  // Helper method to get full address
  String getFullAddress() {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (kebeleName != null && kebeleName!.isNotEmpty) parts.add(kebeleName!);
    if (woredaName != null && woredaName!.isNotEmpty) parts.add(woredaName!);
    if (zoneName != null && zoneName!.isNotEmpty) parts.add(zoneName!);
    if (regionName != null && regionName!.isNotEmpty) parts.add(regionName!);
    
    return parts.isNotEmpty ? parts.join(', ') : 'Address not available';
  }
}