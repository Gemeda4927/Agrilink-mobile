import 'dart:io';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';
import 'package:agrilink/features/profile/domain/repository/profile_repository.dart';

/// ================= CREATE PROFILE USE CASE =================
class CreateProfileUseCase {
  final ProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<CreateProfileModel> execute(CreateProfileParams params) async {
    print('🎯 [CreateProfileUseCase] ===== EXECUTING =====');
    print('🎯 [CreateProfileUseCase] Creating profile with:');
    print('🎯 [CreateProfileUseCase]   - fullName: ${params.fullName}');
    print('🎯 [CreateProfileUseCase]   - kebeleld: ${params.kebeleld}'); // ✅ Updated
    print('🎯 [CreateProfileUseCase]   - image: ${params.image != null ? params.image!.path : 'No image'}');

    try {
      final result = await repository.createProfile(
        fullName: params.fullName,
        kebeleld: params.kebeleld, // ✅ Updated parameter name
        image: params.image,
      );
      
      print('✅ [CreateProfileUseCase] Profile created successfully');
      print('🎯 [CreateProfileUseCase] ===== COMPLETED =====');
      return result;
    } catch (e, stackTrace) {
      print('❌ [CreateProfileUseCase] Failed to create profile: $e');
      print('❌ [CreateProfileUseCase] Stack trace: $stackTrace');
      print('🎯 [CreateProfileUseCase] ===== FAILED =====');
      rethrow;
    }
  }
}

/// ================= UPDATE PROFILE USE CASE =================
class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UpdateProfileModel> execute(UpdateProfileParams params) async {
    print('🎯 [UpdateProfileUseCase] ===== EXECUTING =====');
    print('🎯 [UpdateProfileUseCase] Updating profile with:');
    print('🎯 [UpdateProfileUseCase]   - fullName: ${params.fullName}');
    print('🎯 [UpdateProfileUseCase]   - kebeleld: ${params.kebeleld}'); // ✅ Updated
    print('🎯 [UpdateProfileUseCase]   - image: ${params.image != null ? params.image!.path : 'No image'}');

    try {
      final result = await repository.updateProfile(
        fullName: params.fullName,
        kebeleld: params.kebeleld, // ✅ Updated parameter name
        image: params.image,
      );
      
      print('✅ [UpdateProfileUseCase] Profile updated successfully');
      print('🎯 [UpdateProfileUseCase] ===== COMPLETED =====');
      return result;
    } catch (e, stackTrace) {
      print('❌ [UpdateProfileUseCase] Failed to update profile: $e');
      print('❌ [UpdateProfileUseCase] Stack trace: $stackTrace');
      print('🎯 [UpdateProfileUseCase] ===== FAILED =====');
      rethrow;
    }
  }
}

/// ================= GET PROFILE USE CASE =================
class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<GetProfileModel> execute(String userId) async {
    print('🎯 [GetProfileUseCase] ===== EXECUTING =====');
    print('🎯 [GetProfileUseCase] Fetching profile for userId: $userId');

    try {
      final result = await repository.getProfile(userId);
      
      print('✅ [GetProfileUseCase] Profile fetched successfully');
      print('🎯 [GetProfileUseCase] ===== COMPLETED =====');
      return result;
    } catch (e, stackTrace) {
      print('❌ [GetProfileUseCase] Failed to fetch profile: $e');
      print('❌ [GetProfileUseCase] Stack trace: $stackTrace');
      print('🎯 [GetProfileUseCase] ===== FAILED =====');
      rethrow;
    }
  }
}

/// ================= PARAMS CLASSES =================
class CreateProfileParams {
  final String fullName;
  final String kebeleld; // ✅ Renamed from kebeleId to kebeleld
  final File? image; // nullable

  CreateProfileParams({
    required this.fullName,
    required this.kebeleld, // ✅ Updated
    this.image,
  });
}

class UpdateProfileParams {
  final String fullName;
  final String kebeleld; // ✅ Renamed from kebeleId to kebeleld
  final File? image; // nullable

  UpdateProfileParams({
    required this.fullName,
    required this.kebeleld, // ✅ Updated
    this.image,
  });
}