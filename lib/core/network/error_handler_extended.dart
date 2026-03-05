import 'package:dio/dio.dart';
import 'error_handler.dart';
import 'api_exception.dart';

class ErrorHandlerExtended {
  // Handle Dio error and return ApiException
  static ApiException handleDioError(DioException e) {
    final message = ErrorHandler.handleDioError(e);
    final type = _getExceptionType(e);
    
    return ApiException(
      message: message,
      statusCode: e.response?.statusCode,
      originalError: e,
      type: type,
    );
  }

  // Determine exception type
  static ExceptionType _getExceptionType(DioException e) {
    if (ErrorHandler.isNetworkError(e)) {
      return ExceptionType.network;
    } else if (ErrorHandler.isAuthError(e)) {
      return ExceptionType.authentication;
    } else if (ErrorHandler.isServerError(e)) {
      return ExceptionType.server;
    } else if (ErrorHandler.isClientError(e)) {
      final code = e.response?.statusCode;
      if (code == 422) return ExceptionType.validation;
      return ExceptionType.client;
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ExceptionType.timeout;
      case DioExceptionType.cancel:
        return ExceptionType.cancellation;
      default:
        return ExceptionType.unknown;
    }
  }

  // Generic error handler for any exception
  static String handleGenericError(dynamic error) {
    if (error is DioException) {
      return ErrorHandler.handleDioError(error);
    } else if (error is ApiException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else {
      return 'An unexpected error occurred.';
    }
  }
}