

abstract class AuthEvent {
  const AuthEvent();
}

class SignInEvent extends AuthEvent {
  final Map<String, dynamic> data;
  SignInEvent({required this.data});
}

class SignUpEvent extends AuthEvent {
  final Map<String, dynamic> data;
  SignUpEvent({required this.data});
}

class VerifyOtpEvent extends AuthEvent {
  final Map<String, dynamic> data;
  VerifyOtpEvent({required this.data});
}

class GoogleSignInEvent extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final Map<String, dynamic> data;
  ForgotPasswordEvent({required this.data});
}

class ResetPasswordEvent extends AuthEvent {
  final Map<String, dynamic> data;
  ResetPasswordEvent({required this.data});
}

class LogoutEvent extends AuthEvent {}
