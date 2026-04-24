import 'dart:io';

abstract class ProfileEvent {
  const ProfileEvent();
}

class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile({required this.userId});
}

class CreateProfile extends ProfileEvent {
  final String fullName;
  final String kebeleId;
  final File? image;
  final double? latitude;
  final double? longitude;

  const CreateProfile({
    required this.fullName,
    required this.kebeleId,
    this.image,
    this.latitude,
    this.longitude,
  });
}

class UpdateProfile extends ProfileEvent {
  final String fullName;
  final String kebeleId;
  final File? image;
  final double? latitude;
  final double? longitude;

  const UpdateProfile({
    required this.fullName,
    required this.kebeleId,
    this.image,
    this.latitude,
    this.longitude,
  });
}