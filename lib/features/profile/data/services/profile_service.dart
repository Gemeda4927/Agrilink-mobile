import 'dart:io';
import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';
import 'package:dio/dio.dart';

class ProfileService {
  final DioClient dioClient;

  ProfileService({required this.dioClient});

  /// ================= CREATE PROFILE =================
  Future<CreateProfileModel> createProfile({
    required String fullName,
    required String kebeleld, // ✅ Fixed parameter name
    File? image,
  }) async {
    print('🔵 [ProfileService] ===== CREATE PROFILE STARTED =====');
    print('🔵 [ProfileService] Creating profile with:');
    print('🔵 [ProfileService]   - fullName: $fullName');
    print('🔵 [ProfileService]   - kebeleld: $kebeleld');
    print('🔵 [ProfileService]   - image: ${image != null ? image.path : 'No image provided'}');

    try {
      final formData = FormData.fromMap({
        'fullName': fullName,
        'kebeleld': kebeleld, // ✅ Using correct field name
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      // Log FormData fields to verify
      print('🔵 [ProfileService] FormData fields:');
      formData.fields.forEach((field) {
        print('🔵 [ProfileService]   - ${field.key}: ${field.value}');
      });

      print('🔵 [ProfileService] Making POST request to: ${ApiConstants.profileCreate}');

      // ✅ Remove the options parameter - DioClient handles headers
      final response = await dioClient.post(
        ApiConstants.profileCreate,
        data: formData,
      );

      print('🔵 [ProfileService] Response received:');
      print('🔵 [ProfileService]   - Status code: ${response.statusCode}');
      print('🔵 [ProfileService]   - Data: ${response.data}');

      if (response.statusCode == 201) {
        print('✅ [ProfileService] Profile created successfully');
        print('🔵 [ProfileService] ===== CREATE PROFILE COMPLETED =====');
        return CreateProfileModel.fromJson(response.data);
      } else {
        print('❌ [ProfileService] Failed to create profile. Status code: ${response.statusCode}');
        print('❌ [ProfileService] Response data: ${response.data}');
        throw Exception('Failed to create profile. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [ProfileService] DioException in createProfile:');
      print('❌ [ProfileService]   - Type: ${e.type}');
      print('❌ [ProfileService]   - Message: ${e.message}');
      print('❌ [ProfileService]   - Response status: ${e.response?.statusCode}');
      print('❌ [ProfileService]   - Response data: ${e.response?.data}');
      throw Exception('Failed to create profile: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ [ProfileService] Exception in createProfile: $e');
      print('❌ [ProfileService] Stack trace: $stackTrace');
      print('🔵 [ProfileService] ===== CREATE PROFILE FAILED =====');
      throw Exception('Failed to create profile: $e');
    }
  }

  /// ================= UPDATE PROFILE =================
  Future<UpdateProfileModel> updateProfile({
    required String fullName,
    required String kebeleld,
    File? image,
  }) async {
    print('🔵 [ProfileService] ===== UPDATE PROFILE STARTED =====');
    print('🔵 [ProfileService] Updating profile with:');
    print('🔵 [ProfileService]   - fullName: $fullName');
    print('🔵 [ProfileService]   - kebeleld: $kebeleld');
    print('🔵 [ProfileService]   - image: ${image != null ? image.path : 'No image provided'}');

    try {
      final formData = FormData.fromMap({
        'fullName': fullName,
        'kebeleld': kebeleld,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      print('🔵 [ProfileService] Making PATCH request to: ${ApiConstants.profileUpdate}');

      final response = await dioClient.patch(
        ApiConstants.profileUpdate,
        data: formData,
      );

      print('🔵 [ProfileService] Response received:');
      print('🔵 [ProfileService]   - Status code: ${response.statusCode}');
      print('🔵 [ProfileService]   - Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ [ProfileService] Profile updated successfully');
        return UpdateProfileModel.fromJson(response.data);
      } else {
        print('❌ [ProfileService] Failed to update profile. Status code: ${response.statusCode}');
        throw Exception('Failed to update profile. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [ProfileService] Exception in updateProfile: $e');
      print('❌ [ProfileService] Stack trace: $stackTrace');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// ================= GET PROFILE BY USER ID =================
  Future<GetProfileModel> getProfile(String userId) async {
    print('🔵 [ProfileService] ===== GET PROFILE STARTED =====');
    print('🔵 [ProfileService] Fetching profile for userId: $userId');

    try {
      final url = "${ApiConstants.profileGetByUser}/$userId";
      print('🔵 [ProfileService] Making GET request to: $url');

      final response = await dioClient.get(url);

      print('🔵 [ProfileService] Response received:');
      print('🔵 [ProfileService]   - Status code: ${response.statusCode}');
      print('🔵 [ProfileService]   - Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ [ProfileService] Profile fetched successfully');
        return GetProfileModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        print('❌ [ProfileService] User not found (404)');
        throw Exception('User not found');
      } else {
        print('❌ [ProfileService] Failed to fetch profile. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch profile. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [ProfileService] Exception in getProfile: $e');
      print('❌ [ProfileService] Stack trace: $stackTrace');
      throw Exception('Failed to fetch profile: $e');
    }
  }
}