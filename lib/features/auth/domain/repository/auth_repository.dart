import 'package:agrilink/features/auth/data/model/auth_model.dart';

abstract class AuthRepository {
  Future<String> signup(Map<String, dynamic> data);
  Future<AuthResponse> verifyOtp(Map<String, dynamic> data);
  Future<AuthResponse> signin(Map<String, dynamic> data);
  Future<AuthResponse> googleSignin();
  Future<String> forgotPassword(Map<String, dynamic> data);
  Future<String> resetPassword(Map<String, dynamic> data);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
}
