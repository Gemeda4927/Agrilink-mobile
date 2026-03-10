import 'package:agrilink/features/auth/domain/entities/auth_response_entity.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:agrilink/features/auth/domain/repository/auth_repository.dart';

/// SignIn Use Case
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<AuthResponseEntity> execute(Map<String, dynamic> data) async {
    final authResponse = await repository.signin(data);

    return AuthResponseEntity(
      user: AuthUserEntity(
        id: authResponse.user.id,
        email: authResponse.user.email,
        phone: authResponse.user.phone,
        role: authResponse.user.role,
        status: authResponse.user.status,
        firebaseUid: authResponse.user.firebaseUid,
        createdAt: authResponse.user.createdAt,
      ),
      token: authResponse.token,
    );
  }
}

/// SignUp Use Case
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<String> execute(Map<String, dynamic> data) async {
    return await repository.signup(data);
  }
}

/// Verify OTP Use Case
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<AuthResponseEntity> execute(Map<String, dynamic> data) async {
    final authResponse = await repository.verifyOtp(data);

    return AuthResponseEntity(
      user: AuthUserEntity(
        id: authResponse.user.id,
        email: authResponse.user.email,
        phone: authResponse.user.phone,
        role: authResponse.user.role,
        status: authResponse.user.status,
        firebaseUid: authResponse.user.firebaseUid,
        createdAt: authResponse.user.createdAt,
      ),
      token: authResponse.token,
    );
  }
}

/// Google SignIn Use Case
class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<AuthResponseEntity> execute() async {
    final authResponse = await repository.googleSignin();

    return AuthResponseEntity(
      user: AuthUserEntity(
        id: authResponse.user.id,
        email: authResponse.user.email,
        phone: authResponse.user.phone,
        role: authResponse.user.role,
        status: authResponse.user.status,
        firebaseUid: authResponse.user.firebaseUid,
        createdAt: authResponse.user.createdAt,
      ),
      token: authResponse.token,
    );
  }
}

/// Forgot Password Use Case
class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<String> execute(Map<String, dynamic> data) async {
    return await repository.forgotPassword(data);
  }
}

/// Reset Password Use Case
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<String> execute(Map<String, dynamic> data) async {
    return await repository.resetPassword(data);
  }
}