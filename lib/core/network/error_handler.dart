import 'package:dio/dio.dart';

class ErrorHandler {
  // Handle Dio errors and return user-friendly messages
  static String handleDioError(DioException e) {
    if (e.response != null) {
      // Server responded with an error status code
      return _handleResponseError(e);
    } else {
      // Network or other errors
      return _handleNetworkError(e);
    }
  }

  // Handle response errors based on status code
  static String _handleResponseError(DioException e) {
    final responseData = e.response?.data;
    final statusCode = e.response?.statusCode;

    // Extract error message from response if available
    if (responseData != null) {
      final errorMessage = _extractErrorMessage(responseData);
      if (errorMessage != null) return errorMessage;
    }

    // Fallback to status code based messages
    return _getStatusCodeMessage(statusCode);
  }

  // Extract error message from various response formats
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      // Check common error message fields
      if (responseData['message'] != null) {
        return responseData['message'] as String;
      } else if (responseData['error'] != null) {
        if (responseData['error'] is Map) {
          return responseData['error']['message'] ??
              responseData['error'].toString();
        }
        return responseData['error'] as String;
      } else if (responseData['errors'] != null) {
        // Handle validation errors
        final errors = responseData['errors'];
        if (errors is Map) {
          return errors.values.first.toString();
        } else if (errors is List) {
          return errors.join('\n');
        }
      } else if (responseData['detail'] != null) {
        return responseData['detail'] as String;
      }
    } else if (responseData is String) {
      return responseData;
    }
    return null;
  }

  // Get user-friendly message based on status code
  static String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please check your credentials.';
      case 403:
        return 'Forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. Resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again.';
      default:
        return statusCode != null
            ? 'Error $statusCode occurred.'
            : 'An unknown error occurred.';
    }
  }

  // Handle network-related errors
  static String _handleNetworkError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.badCertificate:
        return 'Invalid SSL certificate. Please check your connection.';

      case DioExceptionType.badResponse:
        return 'Invalid response from server.';

      case DioExceptionType.unknown:
        if (e.message != null && e.message!.contains('SocketException')) {
          return 'Network error. Please check your internet connection.';
        }
        return 'Unexpected error: ${e.message ?? 'Unknown error'}';
    }
  }

  // Check if error is network related
  static bool isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  // Check if error is authentication related
  static bool isAuthError(DioException e) {
    return e.response?.statusCode == 401 || e.response?.statusCode == 403;
  }

  // Check if error is server error (5xx)
  static bool isServerError(DioException e) {
    final code = e.response?.statusCode;
    return code != null && code >= 500 && code < 600;
  }

  // Check if error is client error (4xx)
  static bool isClientError(DioException e) {
    final code = e.response?.statusCode;
    return code != null && code >= 400 && code < 500;
  }
}
