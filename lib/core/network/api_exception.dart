class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final ExceptionType type;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.type = ExceptionType.unknown,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode, Type: $type)';
}

enum ExceptionType {
  network,
  authentication,
  validation,
  server,
  client,
  timeout,
  cancellation,
  unknown,
}