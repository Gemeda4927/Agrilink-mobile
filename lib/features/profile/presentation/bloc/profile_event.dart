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

  const CreateProfile({
    required this.fullName,
    required this.kebeleId,
    this.image,
  });
}

class UpdateProfile extends ProfileEvent {
  final String fullName;
  final String kebeleId;
  final File? image;

  const UpdateProfile({
    required this.fullName,
    required this.kebeleId,
    this.image,
  });
}