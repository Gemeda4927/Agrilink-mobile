import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/core/network/error_handler.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final DioClient dioClient;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthService({
    required this.dioClient,
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  /// SAVE USER + TOKEN
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final user = data["user"];
    final token = data["token"];

    await prefs.setString("token", token ?? "");
    await prefs.setString("id", user["id"] ?? "");
    await prefs.setString("email", user["email"] ?? "");
    await prefs.setString("phone", user["phone"] ?? "");
    await prefs.setString("role", user["role"] ?? "");
  }

 
  Future<AuthUserEntity?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getString("id");
    final email = prefs.getString("email");
    final phone = prefs.getString("phone");
    final role = prefs.getString("role");

    if (id == null || role == null) return null;

    return AuthUserEntity(
      id: id,
      email: email ?? "",
      phone: phone ?? "",
      role: role,
      status: "ACTIVE",
      firebaseUid: null,
      createdAt: DateTime.now(),
    );
  }

  /// SIGNUP
  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.signup,
        data: data,
      );

      final result = _handleResponse(response);
      return result;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// VERIFY OTP
  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.verifyOtp,
        data: data,
      );

      final result = _handleResponse(response);
      return result;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// SIGNIN
  Future<Map<String, dynamic>> signin(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.signin,
        data: data,
      );

      final result = _handleResponse(response);

      /// SAVE USER + TOKEN AFTER LOGIN
      await _saveAuthData(result);

      return result;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// GOOGLE SIGNIN
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await firebaseAuth.signInWithCredential(credential);

    await sendGoogleTokenToBackend(userCredential.user);

    return userCredential.user;
  }

  /// SEND GOOGLE TOKEN TO BACKEND
  Future<Map<String, dynamic>> sendGoogleTokenToBackend(User? user) async {
    if (user == null) throw 'User is null';

    try {
      final idToken = await user.getIdToken();

      final response = await dioClient.post(
        ApiConstants.googleSignin,
        data: {
          'idToken': idToken,
          'email': user.email,
          'name': user.displayName,
        },
      );

      final result = _handleResponse(response);

      /// SAVE USER DATA
      await _saveAuthData(result);

      return result;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// FORGOT PASSWORD
  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.forgotPassword,
        data: data,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// RESET PASSWORD
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.resetPassword,
        data: data,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// HANDLE RESPONSE
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'message': response.data?.toString() ?? ''};
  }
}