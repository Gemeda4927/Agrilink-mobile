import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/features/role_request/data/models/role_request_model.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleRequestService {
  final DioClient client;
  final SharedPreferences? prefs;

  RoleRequestService(this.client, [this.prefs]);

  Future<RoleRequestModel> createRoleRequest({
    required String kebeleId,
    required bool experienceInAgriculture,
    required String currentRole,
    required String educationLevel,
    required bool digitalSkills,
    required bool governmentAssigned,
    List<String>? filePaths,
  }) async {
    final missingFields = <String>[];
    if (kebeleId.isEmpty) missingFields.add('kebeleId');
    if (currentRole.isEmpty) missingFields.add('currentRole');
    if (educationLevel.isEmpty) missingFields.add('educationLevel');

    if (missingFields.isNotEmpty) {
      throw Exception('Missing required fields: ${missingFields.join(', ')}');
    }

    final formData = FormData.fromMap({
      'kebeleId': kebeleId,
      'experienceInAgriculture': experienceInAgriculture,
      'digitalSkills': digitalSkills,
      'governmentAssigned': governmentAssigned,
      'currentRole': currentRole,
      'educationLevel': educationLevel,
    });

    if (filePaths != null && filePaths.isNotEmpty) {
      for (var i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        final file = await MultipartFile.fromFile(filePath);
        formData.files.add(MapEntry('files', file));
      }
    }

    try {
      final response = await client.post(
        ApiConstants.roleRequest,
        data: formData,
      );

      await prefs?.setBool('has_submitted_role_request', true);
      await prefs?.setString('role_request_status', 'PENDING');
      await prefs?.setString(
        'role_request_date',
        DateTime.now().toIso8601String(),
      );

      return RoleRequestModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  bool hasSubmittedRequest() {
    return prefs?.getBool('has_submitted_role_request') ?? false;
  }

  String getRequestStatus() {
    return prefs?.getString('role_request_status') ?? 'NONE';
  }

  Future<void> clearRequestStatus() async {
    await prefs?.remove('has_submitted_role_request');
    await prefs?.remove('role_request_status');
    await prefs?.remove('role_request_date');
  }
}
