class AllProductsResponse {
  final int result;
  final List<Product> products;

  AllProductsResponse({required this.result, required this.products});

  factory AllProductsResponse.fromJson(Map<String, dynamic> json) {
    // Format 1: { "result": 2, "product": [...] }
    if (json.containsKey('product')) {
      final productsList = json['product'] as List?;
      return AllProductsResponse(
        result: json['result'] ?? 0,
        products:
            productsList?.map((item) => Product.fromJson(item)).toList() ?? [],
      );
    }

    // Format 3: Empty or unknown format
    return AllProductsResponse(result: 0, products: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'product': products.map((e) => e.toJson()).toList(),
    };
  }
}

// features/insight/data/model/market_insight.dart

class Product {
  final String id;
  final String name;
  final String? farmerId;
  final String? subCategoryId;
  final int amount;
  final double price;
  final String? description;
  final String? image;
  final String? city;
  final bool withDelivery;
  final DateTime createdAt;
  final SubCategoryInfo? subCategory;
  final FarmerInfo? farmer;
  final String? status; // APPROVED, PENDING, REJECTED

  Product({
    required this.id,
    required this.name,
    this.farmerId,
    this.subCategoryId,
    required this.amount,
    required this.price,
    this.description,
    this.image,
    this.city,
    required this.withDelivery,
    required this.createdAt,
    this.subCategory,
    this.farmer,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse price (handles String, int, double)
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Helper function to safely parse amount (handles String, int)
    int parseAmount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      farmerId: json['farmerId']?.toString(),
      subCategoryId: json['subCategoryId']?.toString(),
      amount: parseAmount(json['amount']),
      price: parsePrice(json['price']),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      city: json['city']?.toString(),
      withDelivery: json['withDelivery'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      subCategory: json['subCategory'] != null
          ? SubCategoryInfo.fromJson(json['subCategory'])
          : null,
      farmer: json['farmer'] != null
          ? FarmerInfo.fromJson(json['farmer'])
          : null,
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farmerId': farmerId,
      'subCategoryId': subCategoryId,
      'amount': amount,
      'price': price,
      'description': description,
      'image': image,
      'city': city,
      'withDelivery': withDelivery,
      'createdAt': createdAt.toIso8601String(),
      'subCategory': subCategory?.toJson(),
      'farmer': farmer?.toJson(),
      'status': status,
    };
  }

  /// Check if product is approved for buyers
  bool get isApproved => status == 'APPROVED' || status == null;
}

/// SubCategory information
class SubCategoryInfo {
  final String id;
  final String name;
  final String? categoryId;
  final CategoryInfo? category;

  SubCategoryInfo({
    required this.id,
    required this.name,
    this.categoryId,
    this.category,
  });

  factory SubCategoryInfo.fromJson(Map<String, dynamic> json) {
    return SubCategoryInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      category: json['category'] != null
          ? CategoryInfo.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'category': category?.toJson(),
    };
  }
}

/// Category information
class CategoryInfo {
  final String id;
  final String name;

  CategoryInfo({required this.id, required this.name});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

/// Farmer/User information (complete)
class FarmerInfo {
  final String id;
  final String? phone;
  final String email;
  final String role;
  final String status;
  final DateTime? createdAt;
  final ProfileInfo? profile;

  FarmerInfo({
    required this.id,
    this.phone,
    required this.email,
    required this.role,
    required this.status,
    this.createdAt,
    this.profile,
  });

  factory FarmerInfo.fromJson(Map<String, dynamic> json) {
    return FarmerInfo(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      profile: json['profile'] != null
          ? ProfileInfo.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'role': role,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }
}

/// Profile information
class ProfileInfo {
  final String id;
  final String userId;
  final String? fullName;
  final String? profileImage;
  final String? bio;

  ProfileInfo({
    required this.id,
    required this.userId,
    this.fullName,
    this.profileImage,
    this.bio,
  });

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      profileImage: json['profileImage']?.toString(),
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'profileImage': profileImage,
      'bio': bio,
    };
  }
}

/// Request model for POST /market-price
class MarketPriceRequest {
  final String productId;
  final String woredaId;
  final double price;
  final String latitude;
  final String longitude;

  MarketPriceRequest({
    required this.productId,
    required this.woredaId,
    required this.price,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'woredaId': woredaId,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Response model for GET /market-price and GET /market-price/approved
class MarketPriceResponse {
  final String id;
  final String userId;
  final String productId;
  final String woredaId;
  final double price;
  final String date;
  final String latitude;
  final String longitude;
  final String status;
  final UserInfo? user;
  final ProductInfo? product;
  final WoredaInfo? woreda;

  MarketPriceResponse({
    required this.id,
    required this.userId,
    required this.productId,
    required this.woredaId,
    required this.price,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.user,
    this.product,
    this.woreda,
  });

  factory MarketPriceResponse.fromJson(Map<String, dynamic> json) {
    return MarketPriceResponse(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      woredaId: json['woredaId']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
      product: json['product'] != null
          ? ProductInfo.fromJson(json['product'])
          : null,
      woreda: json['woreda'] != null
          ? WoredaInfo.fromJson(json['woreda'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'woredaId': woredaId,
      'price': price,
      'date': date,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'user': user?.toJson(),
      'product': product?.toJson(),
      'woreda': woreda?.toJson(),
    };
  }

  bool get isApproved => status.toUpperCase() == 'APPROVED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
}

/// User information (nested in market price response)
class UserInfo {
  final String id;
  final String? phone;
  final String email;
  final String role;
  final String status;

  UserInfo({
    required this.id,
    this.phone,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'role': role,
      'status': status,
    };
  }
}

/// Product information (nested in market price response)
class ProductInfo {
  final String id;
  final String name;
  final double? price;
  final String? image;

  ProductInfo({required this.id, required this.name, this.price, this.image});

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble(),
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'image': image};
  }
}

/// Woreda information (nested in market price response)
class WoredaInfo {
  final String id;
  final String name;
  final String? zoneId;

  WoredaInfo({required this.id, required this.name, this.zoneId});

  factory WoredaInfo.fromJson(Map<String, dynamic> json) {
    return WoredaInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      zoneId: json['zoneId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'zoneId': zoneId};
  }
}
