// In your domain/repository/profile_repository.dart
import 'dart:io';

import 'package:agrilink/features/profile/data/model/ProfileModel.dart';

abstract class ProfileRepository {
  Future<CreateProfileModel> createProfile({
    required String fullName,
    required String kebeleld, // ✅ Fixed parameter name
    File? image,
  });

  Future<UpdateProfileModel> updateProfile({
    required String fullName,
    required String kebeleld, // ✅ Fixed parameter name
    File? image,
  });

  Future<GetProfileModel> getProfile(String userId);
}
