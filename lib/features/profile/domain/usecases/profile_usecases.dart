import 'dart:io';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';
import 'package:agrilink/features/profile/domain/repository/profile_repository.dart';

class CreateProfileUseCase {
  final ProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<CreateProfileModel> execute(CreateProfileParams params) async {
    print('🎯 ===== CREATE PROFILE USECASE =====');

    try {
      final result = await repository.createProfile(
        fullName: params.fullName.trim(),
        kebeleId: params.kebeleId,
        image: params.image,
      );

      print('✅ Profile created');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      rethrow;
    }
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UpdateProfileModel> execute(UpdateProfileParams params) async {
    print('🎯 ===== UPDATE PROFILE USECASE =====');

    try {
      final result = await repository.updateProfile(
        fullName: params.fullName.trim(),
        kebeleId: params.kebeleId,
        image: params.image,
      );

      print('✅ Profile updated');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      rethrow;
    }
  }
}

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<GetProfileModel> execute(String userId) async {
    print('🎯 ===== GET PROFILE USECASE =====');

    try {
      final result = await repository.getProfile(userId);

      print('✅ Profile fetched');
      return result;
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print(stackTrace);
      rethrow;
    }
  }
}

class CreateProfileParams {
  final String fullName;
  final String kebeleId;
  final File? image;

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
