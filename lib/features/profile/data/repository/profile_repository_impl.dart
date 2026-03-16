import 'dart:io';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';
import 'package:agrilink/features/profile/domain/repository/profile_repository.dart';
import '../services/profile_service.dart';

/// ================= PROFILE REPOSITORY IMPLEMENTATION =================
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService profileService;

  ProfileRepositoryImpl({required this.profileService});

  /// Create profile with optional image
  @override
  Future<CreateProfileModel> createProfile({
    required String fullName,
    required String kebeleld, // ✅ Fixed parameter name to match API
    File? image, // nullable
  }) async {
    print('📦 [ProfileRepository] ===== CREATE PROFILE REPOSITORY =====');
    print('📦 [ProfileRepository] Creating profile with:');
    print('📦 [ProfileRepository]   - fullName: $fullName');
    print('📦 [ProfileRepository]   - kebeleld: $kebeleld');
    print('📦 [ProfileRepository]   - image: ${image != null ? image.path : 'No image'}');

    try {
      final result = await profileService.createProfile(
        fullName: fullName,
        kebeleld: kebeleld, // ✅ Passing corrected parameter
        image: image,
      );
      
      print('✅ [ProfileRepository] Profile created successfully');
      print('📦 [ProfileRepository] ===== CREATE PROFILE COMPLETED =====');
      return result;
    } catch (e, stackTrace) {
      print('❌ [ProfileRepository] Failed to create profile: $e');
      print('❌ [ProfileRepository] Stack trace: $stackTrace');
      print('📦 [ProfileRepository] ===== CREATE PROFILE FAILED =====');
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Update profile with optional image
  @override
  Future<UpdateProfileModel> updateProfile({
    required String fullName,
    required String kebeleld, // ✅ Fixed parameter name to match API
    File? image, // nullable
  }) async {
    print('📦 [ProfileRepository] ===== UPDATE PROFILE REPOSITORY =====');
    print('📦 [ProfileRepository] Updating profile with:');
    print('📦 [ProfileRepository]   - fullName: $fullName');
    print('📦 [ProfileRepository]   - kebeleld: $kebeleld');
    print('📦 [ProfileRepository]   - image: ${image != null ? image.path : 'No image'}');

    try {
      final result = await profileService.updateProfile(
        fullName: fullName,
        kebeleld: kebeleld, // ✅ Passing corrected parameter
        image: image,
      );
      
      print('✅ [ProfileRepository] Profile updated successfully');
      print('📦 [ProfileRepository] ===== UPDATE PROFILE COMPLETED =====');
      return result;
    } catch (e, stackTrace) {
      print('❌ [ProfileRepository] Failed to update profile: $e');
      print('❌ [ProfileRepository] Stack trace: $stackTrace');
      print('📦 [ProfileRepository] ===== UPDATE PROFILE FAILED =====');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Get profile by userId
  @override
  Future<GetProfileModel> getProfile(String userId) async {
    print('📦 [ProfileRepository] ===== GET PROFILE REPOSITORY =====');
    print('📦 [ProfileRepository] Fetching profile for userId: $userId');

    try {
      final result = await profileService.getProfile(userId);
      
      print('✅ [ProfileRepository] Profile fetched successfully');
      print('📦 [ProfileRepository] ===== GET PROFILE COMPLETED =====');
      return result;
    } catch (e, stackTrace) {
      print('❌ [ProfileRepository] Failed to fetch profile: $e');
      print('❌ [ProfileRepository] Stack trace: $stackTrace');
      print('📦 [ProfileRepository] ===== GET PROFILE FAILED =====');
      throw Exception('Failed to fetch profile: $e');
    }
  }
}