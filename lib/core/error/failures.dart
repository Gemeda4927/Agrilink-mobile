abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});
}

// Server Failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Authentication Failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}
