/// ================= CREATE PROFILE MODEL =================
class CreateProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String kebeleId;
  final String? imageUrl;

  CreateProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    this.imageUrl,
  });

  factory CreateProfileModel.fromJson(Map<String, dynamic> json) {
    return CreateProfileModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString().trim(),
      kebeleId: (json['kebeleId'] ?? '').toString(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName.trim(),
      "kebeleId": kebeleId,
      "imageUrl": imageUrl,
    };
  }
}

/// ================= UPDATE PROFILE MODEL =================
class UpdateProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String kebeleId;
  final String? imageUrl;

  UpdateProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    this.imageUrl,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString().trim(),
      kebeleId: (json['kebeleId'] ?? '').toString(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName.trim(),
      "kebeleId": kebeleId,
      "imageUrl": imageUrl,
    };
  }
}

/// ================= GET PROFILE MODEL =================
class GetProfileModel {
  final String id;
  final String phone;
  final String email;
  final String role;
  final String status;
  final String createdAt;
  final ProfileData? profile;

  GetProfileModel({
    required this.id,
    required this.phone,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.profile,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) {
    return GetProfileModel(
      id: (json['id'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      profile: json['profile'] != null
          ? ProfileData.fromJson(json['profile'])
          : null,
    );
  }
}

/// ================= PROFILE DATA =================
class ProfileData {
  final String id;
  final String userId;
  final String fullName;
  final String kebeleId;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final KebeleData? kebele;

  ProfileData({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.kebele,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString().trim(),
      kebeleId: (json['kebeleId'] ?? '').toString(),
      imageUrl: json['imageUrl'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      kebele: json['kebele'] != null
          ? KebeleData.fromJson(json['kebele'])
          : null,
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      print('Error parsing double from string "$value": $e');
      return null;
    }
  }
  return null;
}

/// ================= KEBELE DATA =================
class KebeleData {
  final String id;
  final String name;
  final String woredaId;
  final WoredaData? woreda;

  KebeleData({
    required this.id,
    required this.name,
    required this.woredaId,
    this.woreda,
  });

  factory KebeleData.fromJson(Map<String, dynamic> json) {
    return KebeleData(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      woredaId: (json['woredaId'] ?? '').toString(),
      woreda: json['woreda'] != null
          ? WoredaData.fromJson(json['woreda'])
          : null,
    );
  }
}

/// ================= WOREDA DATA =================
class WoredaData {
  final String id;
  final String name;
  final String zoneId;
  final ZoneData? zone;

  WoredaData({
    required this.id,
    required this.name,
    required this.zoneId,
    this.zone,
  });

  factory WoredaData.fromJson(Map<String, dynamic> json) {
    return WoredaData(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      zoneId: (json['zoneId'] ?? '').toString(),
      zone: json['zone'] != null ? ZoneData.fromJson(json['zone']) : null,
    );
  }
}

/// ================= ZONE DATA =================
class ZoneData {
  final String id;
  final String name;
  final String regionId;
  final RegionData? region;

  ZoneData({
    required this.id,
    required this.name,
    required this.regionId,
    this.region,
  });

  factory ZoneData.fromJson(Map<String, dynamic> json) {
    return ZoneData(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      regionId: (json['regionId'] ?? '').toString(),
      region: json['region'] != null
          ? RegionData.fromJson(json['region'])
          : null,
    );
  }
}

/// ================= REGION DATA =================
class RegionData {
  final String id;
  final String name;

  RegionData({required this.id, required this.name});

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
    );
  }
}
