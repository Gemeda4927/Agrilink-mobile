import 'dart:io';

class Profile {
  final String id;
  final String userId;
  final String fullName;
  final String kebeleId;
  final String imageUrl;

  Profile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.kebeleId,
    required this.imageUrl,
  });
}

class CreateProfileParams {
  final String fullName;
  final String kebeleId;
  final File? image; // nullable now

  CreateProfileParams({
    required this.fullName,
    required this.kebeleId,
    this.image,
  });
}

class UpdateProfileParams {
  final String fullName;
  final String kebeleId;
  final File? image; 

  UpdateProfileParams({
    required this.fullName,
    required this.kebeleId,
    this.image,
  });
}