import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class RoleRequestService {
  final DioClient client;

  RoleRequestService(this.client);

  /// Submit role request to API
  Future<Map<String, dynamic>> createRoleRequest({
    required String kebeleId,
    required bool experienceInAgriculture,
    required String requestedRole,
    required String currentRole,
    required String educationLevel,
    required bool digitalSkills,
    required bool governmentAssigned,
    List<String>? filePaths,
  }) async {
    // ✅ Validate required fields
    final missingFields = <String>[];
    if (kebeleId.isEmpty) missingFields.add('kebeleId');
    if (requestedRole.isEmpty) missingFields.add('requestedRole');
    if (currentRole.isEmpty) missingFields.add('currentRole');
    if (educationLevel.isEmpty) missingFields.add('educationLevel');

    if (missingFields.isNotEmpty) {
      throw Exception('Missing required fields: ${missingFields.join(', ')}');
    }

    // ✅ Build FormData
    final formData = FormData.fromMap({
      'kebeleId': kebeleId,
      'experienceInAgriculture': experienceInAgriculture,
      'requestedRole': requestedRole,
      'currentRole': currentRole,
      'educationLevel': educationLevel,
      'digitalSkills': digitalSkills,
      'governmentAssigned': governmentAssigned,
    });

    // ✅ Add files if provided
    if (filePaths != null && filePaths.isNotEmpty) {
      for (final filePath in filePaths) {
        try {
          final file = await MultipartFile.fromFile(filePath);
          formData.files.add(MapEntry('files', file));
        } catch (e) {
          throw Exception('Failed to load file: $filePath. Error: $e');
        }
      }
    }

    try {
      final response = await client.post(
        ApiConstants.roleRequest,
        data: formData,
      );

      // ✅ Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ??
              'Role request submitted successfully',
          'data': response.data,
        };
      } else {
        throw Exception('Failed to submit request: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  /// Handle Dio errors
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      switch (statusCode) {
        case 400:
          return 'Bad request: ${_extractErrorMessage(data)}';
        case 401:
          return 'Unauthorized: Please login again';
        case 403:
          return 'Forbidden: You don\'t have permission to request role change';
        case 409:
          return 'You already have a pending request. Please wait for approval.';
        case 422:
          return 'Validation error: ${_extractErrorMessage(data)}';
        case 429:
          return 'Too many requests. Please try again later.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return _extractErrorMessage(data) ?? 'Something went wrong';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout. Server is not responding.';
    } else if (e.type == DioExceptionType.sendTimeout) {
      return 'Send timeout. Unable to send data to server.';
    } else if (e.type == DioExceptionType.cancel) {
      return 'Request was cancelled.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Connection error. Please check your internet connection.';
    } else if (e.type == DioExceptionType.unknown) {
      if (e.message?.contains('SocketException') == true) {
        return 'Network error. Unable to connect to server.';
      }
      return 'Unknown error: ${e.message}';
    } else {
      return 'Network error: ${e.message}';
    }
  }

  /// Extract error message from response
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map) {
          return errors.values.join(', ');
        }
        if (errors is List) {
          return errors.join(', ');
        }
      }
    }
    return null;
  }
}

// ================= RESPONSE MODEL =================

class RoleRequestResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  RoleRequestResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RoleRequestResponse.fromJson(Map<String, dynamic> json) {
    return RoleRequestResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json,
    );
  }

  factory RoleRequestResponse.success(String message) {
    return RoleRequestResponse(
      success: true,
      message: message,
    );
  }

  factory RoleRequestResponse.error(String message) {
    return RoleRequestResponse(
      success: false,
      message: message,
    );
  }
}