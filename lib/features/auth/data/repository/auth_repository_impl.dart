import 'package:agrilink/features/auth/data/model/auth_model.dart';
import 'package:agrilink/core/network/token_manager.dart';
import 'package:agrilink/features/auth/data/service/auth_service.dart';
import 'package:agrilink/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final TokenManager tokenManager;

  AuthRepositoryImpl({
    required this.authService,
    required this.tokenManager,
  });

  @override
  Future<String> signup(Map<String, dynamic> data) async {
    try {
      final json = await authService.signup(data);
      return json['message'] ?? 'Signup successful';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> verifyOtp(Map<String, dynamic> data) async {
    try {
      final json = await authService.verifyOtp(data);
      final authResponse = AuthResponse.fromJson(json);

      if (authResponse.token.isNotEmpty) {
        await tokenManager.saveToken(authResponse.token);
        // Also save user data if needed
        await _saveUserData(authResponse);
      }
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signin(Map<String, dynamic> data) async {
    try {
      final json = await authService.signin(data);
      final authResponse = AuthResponse.fromJson(json);

      if (authResponse.token.isNotEmpty) {
        await tokenManager.saveToken(authResponse.token);
        // Also save user data if needed
        await _saveUserData(authResponse);
      }
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> googleSignin() async {
    try {
      // Step 1: Sign in with Google via Firebase
      final result = await authService.signInWithGoogle();
      
      // The signInWithGoogle now returns Map<String, dynamic> directly
      // This eliminates the null User? issue
      final json = result;
      final authResponse = AuthResponse.fromJson(json);

      // Step 2: Save token locally
      if (authResponse.token.isNotEmpty) {
        await tokenManager.saveToken(authResponse.token);
        await _saveUserData(authResponse);
      }
      
      return authResponse;
    } catch (e) {
      // Clean up any partial state
      await tokenManager.clearToken();
      rethrow;
    }
  }

  @override
  Future<String> forgotPassword(Map<String, dynamic> data) async {
    try {
      final json = await authService.forgotPassword(data);
      return json['message'] ?? 'Password reset email sent';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> resetPassword(Map<String, dynamic> data) async {
    try {
      final json = await authService.resetPassword(data);
      return json['message'] ?? 'Password reset successful';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Also sign out from Google/Firebase if needed
      await authService.signOutFromGoogle();
      await tokenManager.clearToken();
    } catch (e) {
      // Even if sign out fails, clear local token
      await tokenManager.clearToken();
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final hasToken = await tokenManager.hasToken();
      if (!hasToken) return false;
      
      // Optional: Verify token is still valid with backend
      final token = await tokenManager.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await tokenManager.getToken();
    } catch (e) {
      return null;
    }
  }

  // Helper method to save user data
  Future<void> _saveUserData(AuthResponse authResponse) async {
    // For example, save to SharedPreferences or a local database
    if (authResponse.user != null) {
      // Save user data to shared preferences or secure storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', authResponse.user!.id);
      await prefs.setString('user_email', authResponse.user!.email);
      await prefs.setString('user_role', authResponse.user!.role);
    }
  }
}