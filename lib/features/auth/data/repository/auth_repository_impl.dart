import 'package:agrilink/features/auth/data/model/auth_model.dart';
import 'package:agrilink/core/network/token_manager.dart';
import 'package:agrilink/features/auth/data/service/auth_service.dart';
import 'package:agrilink/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final TokenManager tokenManager;

  AuthRepositoryImpl({
    required this.authService,
    required this.tokenManager,
  });

  @override
  Future<String> signup(Map<String, dynamic> data) async {
    final json = await authService.signup(data);
    return json['message'] ?? 'Signup successful';
  }

  @override
  Future<AuthResponse> verifyOtp(Map<String, dynamic> data) async {
    final json = await authService.verifyOtp(data);
    final authResponse = AuthResponse.fromJson(json);

    if (authResponse.token.isNotEmpty) {
      await tokenManager.saveToken(authResponse.token);
    }
    return authResponse;
  }

  @override
  Future<AuthResponse> signin(Map<String, dynamic> data) async {
    final json = await authService.signin(data);
    final authResponse = AuthResponse.fromJson(json);

    if (authResponse.token.isNotEmpty) {
      await tokenManager.saveToken(authResponse.token);
    }
    return authResponse;
  }

  @override
  Future<AuthResponse> googleSignin() async {
    // Step 1: Sign in with Google via Firebase
    final User? user = await authService.signInWithGoogle();
    if (user == null) throw Exception('Google Sign-In cancelled');

    // Step 2: Send token to your backend
    final json = await authService.sendGoogleTokenToBackend(user);
    final authResponse = AuthResponse.fromJson(json);

    // Step 3: Save token locally
    if (authResponse.token.isNotEmpty) {
      await tokenManager.saveToken(authResponse.token);
    }
    return authResponse;
  }

  @override
  Future<String> forgotPassword(Map<String, dynamic> data) async {
    final json = await authService.forgotPassword(data);
    return json['message'] ?? 'Password reset email sent';
  }

  @override
  Future<String> resetPassword(Map<String, dynamic> data) async {
    final json = await authService.resetPassword(data);
    return json['message'] ?? 'Password reset successful';
  }

  @override
  Future<void> logout() async => tokenManager.clearToken();

  @override
  Future<bool> isLoggedIn() async => tokenManager.hasToken();

  @override
  Future<String?> getToken() async => tokenManager.getToken();
}