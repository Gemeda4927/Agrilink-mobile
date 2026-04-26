class AllProductsResponse {
  final int result;
  final List<ProductInfo> products;

  AllProductsResponse({required this.result, required this.products});

  // For Map response: { "result": 2, "product": [...] }
  factory AllProductsResponse.fromJson(Map<String, dynamic> json) {
    final productsList = json['product'] as List?;
    return AllProductsResponse(
      result: json['result'] ?? 0,
      products:
          productsList?.map((item) => ProductInfo.fromJson(item)).toList() ??
          [],
    );
  }

  // For List response: [{...}, {...}]
  factory AllProductsResponse.fromList(List<dynamic> list) {
    return AllProductsResponse(
      result: list.length,
      products: list.map((item) => ProductInfo.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'product': products.map((e) => e.toJson()).toList(),
    };
  }
}

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
  final DateTime date;
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
    // Safe date parsing
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    // Safe double parsing (handles String like "7.6753 N" - extract number)
    double parseCoordinate(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Extract numeric part from strings like "7.6753 N"
        final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(value);
        return match != null ? double.tryParse(match.group(1)!) ?? 0.0 : 0.0;
      }
      return 0.0;
    }

    return MarketPriceResponse(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      woredaId: json['woredaId']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(json['date']),
      latitude: parseCoordinate(json['latitude']).toString(),
      longitude: parseCoordinate(json['longitude']).toString(),
      status: json['status']?.toString()?.toUpperCase() ?? '',
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
      'date': date.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'user': user?.toJson(),
      'product': product?.toJson(),
      'woreda': woreda?.toJson(),
    };
  }

  // Helper getters
  bool get isApproved => status == 'APPROVED';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';

  /// Get numeric latitude as double
  double get latitudeAsDouble => double.tryParse(latitude) ?? 0.0;

  /// Get numeric longitude as double
  double get longitudeAsDouble => double.tryParse(longitude) ?? 0.0;
}

/// User information (nested in market price response)
class UserInfo {
  final String id;
  final String? phone;
  final String email;
  final String? firebaseUid;
  final String role;
  final String status;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final String? createdById;
  final ProfileInfo? profile;

  UserInfo({
    required this.id,
    this.phone,
    required this.email,
    this.firebaseUid,
    required this.role,
    required this.status,
    this.lastLogin,
    this.createdAt,
    this.createdById,
    this.profile,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString(),
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      createdById: json['createdById']?.toString(),
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
      'firebaseUid': firebaseUid,
      'role': role,
      'status': status,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'createdById': createdById,
      'profile': profile?.toJson(),
    };
  }
}

/// Profile information (matching your JSON)
class ProfileInfo {
  final String? fullName;
  final String? profileImage;
  final String? bio;

  ProfileInfo({this.fullName, this.profileImage, this.bio});

  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      fullName: json['fullName']?.toString(),
      profileImage: json['profileImage']?.toString(),
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'profileImage': profileImage, 'bio': bio};
  }
}

/// Woreda info (matching your actual JSON)
class WoredaInfo {
  final String? id;
  final String name;
  final String? zoneId;

  WoredaInfo({this.id, required this.name, this.zoneId});

  factory WoredaInfo.fromJson(Map<String, dynamic> json) {
    return WoredaInfo(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      zoneId: json['zoneId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'zoneId': zoneId};
  }
}

/// Response model for GET /market-price (List response)
class MarketPriceListResponse {
  final List<MarketPriceResponse> items;

  MarketPriceListResponse({required this.items});

  factory MarketPriceListResponse.fromJson(List<dynamic> json) {
    return MarketPriceListResponse(
      items: json.map((item) => MarketPriceResponse.fromJson(item)).toList(),
    );
  }
  List<Map<String, dynamic>> toJson() {
    return items.map((e) => e.toJson()).toList();
  }
}
