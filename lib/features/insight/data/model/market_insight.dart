class AllProductsResponse {
  final int result;
  final List<Product> products;

  AllProductsResponse({required this.result, required this.products});

  factory AllProductsResponse.fromJson(Map<String, dynamic> json) {
    return AllProductsResponse(
      result: json['result'] ?? 0,
      products:
          (json['product'] as List?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'product': products.map((e) => e.toJson()).toList(),
    };
  }
}

/// Product model
class Product {
  final String id;
  final String name;

  Product({required this.id, required this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
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
  final String name;

  ProductInfo({required this.name});

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(name: json['name']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

/// Woreda information (nested in market price response)
class WoredaInfo {
  final String name;

  WoredaInfo({required this.name});

  factory WoredaInfo.fromJson(Map<String, dynamic> json) {
    return WoredaInfo(name: json['name']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
