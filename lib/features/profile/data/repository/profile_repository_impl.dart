import 'dart:io';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';
import 'package:agrilink/features/profile/domain/repository/profile_repository.dart';
import '../services/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService profileService;

  ProfileRepositoryImpl({required this.profileService});

  @override
  Future<CreateProfileModel> createProfile({
    required String fullName,
    required String kebeleId,
    File? image,
    double? latitude,
    double? longitude,
  }) async {
    print('📦 ===== CREATE PROFILE REPOSITORY =====');

    try {
      final result = await profileService.createProfile(
        fullName: fullName.trim(),
        kebeleId: kebeleId,
        image: image,
        latitude: latitude,
        longitude: longitude,
      );

      print('✅ Profile created');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      throw Exception('Failed to create profile: $e');
    }
  }

  @override
  Future<UpdateProfileModel> updateProfile({
    required String fullName,
    required String kebeleId,
    File? image,
    double? latitude,
    double? longitude,
  }) async {
    print('📦 ===== UPDATE PROFILE REPOSITORY =====');

    try {
      final result = await profileService.updateProfile(
        fullName: fullName.trim(),
        kebeleId: kebeleId,
        image: image,
        latitude: latitude,
        longitude: longitude,
      );

      print('✅ Profile updated');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<GetProfileModel> getProfile(String userId) async {
    print('📦 ===== GET PROFILE REPOSITORY =====');

    try {
      final result = await profileService.getProfile(userId);

      print('✅ Profile fetched');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      throw Exception('Failed to fetch profile: $e');
    }
  }
}