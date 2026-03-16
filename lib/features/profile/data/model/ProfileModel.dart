
/// ================= CREATE PROFILE MODEL =================
class CreateProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String kebeleId;
  final String? imageUrl; // optional

  CreateProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    this.imageUrl,
  });

  factory CreateProfileModel.fromJson(Map<String, dynamic> json) {
    return CreateProfileModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      kebeleId: json['kebeleId'] ?? '',
      imageUrl: json['imageUrl'], // nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
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
  final String? imageUrl; // optional

  UpdateProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    this.imageUrl,
  });

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      kebeleId: json['kebeleId'] ?? '',
      imageUrl: json['imageUrl'], // nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
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
  final ProfileData? profile; // Made nullable

  GetProfileModel({
    required this.id,
    required this.phone,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
    this.profile, // Now optional
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) {
    return GetProfileModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      profile: json['profile'] != null 
          ? ProfileData.fromJson(json['profile']) 
          : null, // Handle null profile
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
  final KebeleData? kebele; // Changed to more specific type

  ProfileData({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    this.imageUrl,
    this.kebele,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      kebeleId: json['kebeleId'] ?? '',
      imageUrl: json['imageUrl'],
      kebele: json['kebele'] != null
          ? KebeleData.fromJson(json['kebele'])
          : null,
    );
  }
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      woredaId: json['woredaId'] ?? '',
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      zoneId: json['zoneId'] ?? '',
      zone: json['zone'] != null
          ? ZoneData.fromJson(json['zone'])
          : null,
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      regionId: json['regionId'] ?? '',
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

  RegionData({
    required this.id,
    required this.name,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

/// ================= HELPER EXTENSIONS =================
extension ProfileDataX on ProfileData {
  /// Get full location string
  String get fullLocation {
    final parts = <String>[];
    
    if (kebele != null) {
      parts.add(kebele!.name);
      
      if (kebele!.woreda != null) {
        parts.add(kebele!.woreda!.name);
        
        if (kebele!.woreda!.zone != null) {
          parts.add(kebele!.woreda!.zone!.name);
          
          if (kebele!.woreda!.zone!.region != null) {
            parts.add(kebele!.woreda!.zone!.region!.name);
          }
        }
      }
    }
    
    return parts.isNotEmpty ? parts.join(' > ') : 'Location not specified';
  }

  /// Get region name
  String? get regionName => kebele?.woreda?.zone?.region?.name;

  /// Get zone name
  String? get zoneName => kebele?.woreda?.zone?.name;

  /// Get woreda name
  String? get woredaName => kebele?.woreda?.name;

  /// Get kebele name
  String? get kebeleName => kebele?.name;
}