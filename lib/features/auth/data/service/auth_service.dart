import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/core/network/error_handler.dart';
import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final DioClient dioClient;

  AuthService({required this.dioClient});

  /// Signup
  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(ApiConstants.signup, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw 'Signup failed: $e';
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(ApiConstants.verifyOtp, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw 'Verify OTP failed: $e';
    }
  }

  /// Signin with email & password
  Future<Map<String, dynamic>> signin(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(ApiConstants.signin, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw 'Signin failed: $e';
    }
  }

  // /// Google Signin using Firebase ID token
  // Future<Map<String, dynamic>> googleSignin() async {
  //   try {
  //     // 1️⃣ Trigger Google Sign-In flow
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       return {'message': 'Google Sign-In cancelled by user'};
  //     }

  //     // 2️⃣ Obtain Google auth details
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // 3️⃣ Sign in to Firebase
  //     final UserCredential userCredential = await FirebaseAuth.instance
  //         .signInWithCredential(credential);

  //     // 4️⃣ Get Firebase ID token to send to backend
  //     final String? idToken = await userCredential.user?.getIdToken();
  //     if (idToken == null) {
  //       return {'message': 'Failed to obtain Firebase ID token'};
  //     }

  //     // 5️⃣ Send token to backend
  //     final response = await dioClient.post(
  //       ApiConstants.googleSignin,
  //       data: {'idToken': idToken},
  //     );

  //     return _handleResponse(response);
  //   } on DioException catch (e) {
  //     throw ErrorHandler.handleDioError(e);
  //   } catch (e) {
  //     throw 'Google Sign-In failed: $e';
  //   }
  // }

  /// Forgot Password
  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.forgotPassword,
        data: data,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw 'Forgot Password failed: $e';
    }
  }

  /// Reset Password
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiConstants.resetPassword,
        data: data,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw 'Reset Password failed: $e';
    }
  }

  /// Private helper to ensure we always return a Map
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'message': response.data?.toString() ?? ''};
  }
}
