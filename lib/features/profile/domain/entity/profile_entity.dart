import 'dart:io';

class Profile {
  final String id;
  final String userId;
  final String fullName;
  final String kebeleId;
  final String imageUrl;
  final double? latitude;
  final double? longitude;

  Profile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    required this.imageUrl,
    this.latitude,
    this.longitude,
  });
}

class CreateProfileParams {
  final String fullName;
  final String kebeleId;
  final File? image;
  final double? latitude;
  final double? longitude;

  CreateProfileParams({
    required this.fullName,
    required this.kebeleId,
    this.image,
    this.latitude,
    this.longitude,
  });
}

class UpdateProfileParams {
  final String fullName;
  final String kebeleId;
  final File? image;
  final double? latitude;
  final double? longitude;

  UpdateProfileParams({
    required this.fullName,
    required this.kebeleId,
    this.image,
    this.latitude,
    this.longitude,
  });
}
