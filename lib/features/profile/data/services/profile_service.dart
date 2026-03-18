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
    required String kebeleId,
    File? image,
  }) async {
    print('🔵 ===== CREATE PROFILE STARTED =====');

    try {
      final formData = FormData.fromMap({
        'fullName': fullName.trim(),
        'kebeleId': kebeleId,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await dioClient.post(
        ApiConstants.profileCreate,
        data: formData,
      );

      print('🔵 Status: ${response.statusCode}');
      print('🔵 Data: ${response.data}');

      if (response.statusCode == 201) {
        print('✅ Profile created');
        return CreateProfileModel.fromJson(response.data);
      }

      throw Exception('Failed to create profile: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Dio error: ${e.response?.data}');
      throw Exception(e.response?.data ?? e.message);
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to create profile');
    }
  }

  /// ================= UPDATE PROFILE =================
  Future<UpdateProfileModel> updateProfile({
    required String fullName,
    required String kebeleId,
    File? image,
  }) async {
    print('🔵 ===== UPDATE PROFILE STARTED =====');

    try {
      final formData = FormData.fromMap({
        'fullName': fullName.trim(),
        'kebeleId': kebeleId,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await dioClient.patch(
        ApiConstants.profileUpdate,
        data: formData,
      );

      print('🔵 Status: ${response.statusCode}');
      print('🔵 Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Profile updated');
        return UpdateProfileModel.fromJson(response.data);
      }

      throw Exception('Failed to update profile: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Dio error: ${e.response?.data}');
      throw Exception(e.response?.data ?? e.message);
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to update profile');
    }
  }

  /// ================= GET PROFILE =================
  Future<GetProfileModel> getProfile(String userId) async {
    print('🔵 ===== GET PROFILE STARTED =====');

    try {
      final url = "${ApiConstants.profileGetByUser}/$userId";

      final response = await dioClient.get(url);

      print('🔵 Status: ${response.statusCode}');
      print('🔵 Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Profile fetched');
        return GetProfileModel.fromJson(response.data);
      }

      if (response.statusCode == 404) {
        throw Exception('User not found');
      }

      throw Exception('Failed to fetch profile: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ Dio error: ${e.response?.data}');
      throw Exception(e.response?.data ?? e.message);
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Failed to fetch profile');
    }
  }
}