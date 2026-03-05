
import 'package:agrilink/features/auth/domain/entities/auth_response_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponseEntity authResponse;
  AuthSuccess({required this.authResponse});
}

class AuthMessage extends AuthState {
  final String message;
  AuthMessage({required this.message});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure({required this.error});
}
