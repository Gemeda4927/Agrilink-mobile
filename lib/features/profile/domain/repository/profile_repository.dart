import 'dart:io';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';

abstract class ProfileRepository {
  Future<CreateProfileModel> createProfile({
    required String fullName,
    required String kebeleId, 
    File? image,
  });

  Future<UpdateProfileModel> updateProfile({
    required String fullName,
    required String kebeleId, 
    File? image,
  });

  Future<GetProfileModel> getProfile(String userId);
}