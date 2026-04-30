import 'package:agrilink/core/network/api_constants.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/core/network/error_handler.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ==================== PRIVATE METHODS ====================

  /// Save user data and token to local storage
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    debugPrint('Saving auth data...');
    final prefs = await SharedPreferences.getInstance();

    final user = data["user"];
    final token = data["token"];

    if (token != null) {
      await prefs.setString("token", token);
      debugPrint('Token saved successfully');
    } else {
      debugPrint('Warning: No token found in response');
    }

    if (user != null) {
      await prefs.setString("id", user["id"] ?? "");
      await prefs.setString("email", user["email"] ?? "");
      await prefs.setString("phone", user["phone"] ?? "");
      await prefs.setString("role", user["role"] ?? "");
      debugPrint('User data saved: ${user["email"]} (Role: ${user["role"]})');

      if (user["firebaseUid"] != null) {
        await prefs.setString("firebaseUid", user["firebaseUid"]);
        debugPrint('Firebase UID saved: ${user["firebaseUid"]}');
      }
    } else {
      debugPrint('Warning: No user data found in response');
    }
  }

  /// Handle API response
  Map<String, dynamic> _handleResponse(Response response) {
    debugPrint('Handling API response - Status code: ${response.statusCode}');
    if (response.data is Map<String, dynamic>) {
      debugPrint('Response is valid Map');
      return response.data as Map<String, dynamic>;
    }
    debugPrint('Response is not a Map, returning default message');
    return {'message': response.data?.toString() ?? ''};
  }

  /// Check Google Play Services availability
  Future<bool> _checkGooglePlayServices() async {
    try {
      debugPrint('Checking Google Play Services...');
      final GoogleSignIn googleSignInTest = GoogleSignIn();
      await googleSignInTest.isSignedIn();
      debugPrint('Google Play Services available');
      return true;
    } catch (e) {
      debugPrint('Google Play Services error: $e');
      return false;
    }
  }

  /// Clean up Google Sign-In
  Future<void> _cleanupGoogleSignIn() async {
    try {
      debugPrint('Cleaning up Google Sign-In...');
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      debugPrint('Cleanup completed successfully');
    } catch (e) {
      debugPrint('Error during Google sign-out cleanup: $e');
    }
  }

  /// Send Google token to backend
  Future<Map<String, dynamic>> _sendGoogleTokenToBackend(
    User user,
    String idToken,
  ) async {
    debugPrint('Sending to backend: ${ApiConstants.googleSignin}');

    try {
      final requestData = {
        'idToken': idToken,
        'email': user.email,
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'firebaseUid': user.uid,
      };

      debugPrint('Backend request data:');
      debugPrint('  Endpoint: ${ApiConstants.googleSignin}');
      debugPrint('  Email: ${requestData['email']}');
      debugPrint('  Name: ${requestData['name']}');
      debugPrint('  Firebase UID: ${requestData['firebaseUid']}');
      debugPrint(
        '  Photo URL: ${requestData['photoUrl'] != '' ? 'Present' : 'Not provided'}',
      );

      final response = await dioClient.post(
        ApiConstants.googleSignin,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Validate response
        if (data['token'] == null) {
          throw Exception('Backend response missing token');
        }
        if (data['user'] == null) {
          throw Exception('Backend response missing user data');
        }

        debugPrint('✓ Backend authentication successful');
        debugPrint('  User role: ${data['user']?['role'] ?? 'Unknown'}');
        return data;
      } else {
        throw Exception('Backend returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('✗ Backend error: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception(
          'Authentication failed. Please check:\n'
          '1. Your internet connection\n'
          '2. Backend Google verification setup\n'
          '3. Firebase Admin SDK configuration',
        );
      }
      await _cleanupGoogleSignIn();
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      debugPrint('✗ Unexpected error in backend communication');
      debugPrint('  Error: $e');
      await _cleanupGoogleSignIn();
      rethrow;
    }
  }

  // ==================== PUBLIC METHODS ====================

  /// Get logged in user from local storage
  Future<AuthUserEntity?> getLoggedInUser() async {
    debugPrint('Getting logged in user from local storage...');
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getString("id");
    final email = prefs.getString("email");
    final phone = prefs.getString("phone");
    final role = prefs.getString("role");
    final firebaseUid = prefs.getString("firebaseUid");

    if (id == null || role == null) {
      debugPrint('No logged in user found (id or role is null)');
      return null;
    }

    debugPrint('User found: $email (Role: $role)');
    return AuthUserEntity(
      id: id,
      email: email ?? "",
      phone: phone ?? "",
      role: role,
      status: "ACTIVE",
      firebaseUid: firebaseUid,
      createdAt: DateTime.now(),
    );
  }

  /// Sign up with email/phone
  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    debugPrint(
      'Signup attempt for email/phone: ${data['email'] ?? data['phone']}',
    );
    try {
      final response = await dioClient.post(ApiConstants.signup, data: data);
      final result = _handleResponse(response);
      debugPrint('Signup successful');
      return result;
    } on DioException catch (e) {
      debugPrint('Signup failed: ${e.message}');
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp(Map<String, dynamic> data) async {
    debugPrint('Verifying OTP...');
    try {
      final response = await dioClient.post(ApiConstants.verifyOtp, data: data);
      final result = _handleResponse(response);
      debugPrint('OTP verification successful');
      return result;
    } on DioException catch (e) {
      debugPrint('OTP verification failed: ${e.message}');
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Sign in with email/phone
  Future<Map<String, dynamic>> signin(Map<String, dynamic> data) async {
    debugPrint('Signin attempt for: ${data['email'] ?? data['phone']}');
    try {
      final response = await dioClient.post(ApiConstants.signin, data: data);
      final result = _handleResponse(response);
      debugPrint('Signin successful');
      await _saveAuthData(result);
      return result;
    } on DioException catch (e) {
      debugPrint('Signin failed: ${e.message}');
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    debugPrint('=========================================');
    debugPrint('Starting Google Sign-In process...');
    debugPrint('=========================================');

    try {
      // Check Google Play Services
      final playServicesAvailable = await _checkGooglePlayServices();
      if (!playServicesAvailable) {
        throw Exception(
          'Google Play Services not available. Please update Google Play Services.',
        );
      }

      // Configure Google Sign-In with requested scopes
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out any existing user to ensure fresh sign-in
      await googleSignIn.signOut();
      await Future.delayed(const Duration(milliseconds: 500));

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in cancelled by user');
      }

      debugPrint('✓ Google user: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to authenticate with Firebase');
      }

      debugPrint('✓ Firebase user: ${user.email}');

      // Get fresh ID token
      final idToken = await user.getIdToken(true);
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Send to backend with timeout
      final result = await _sendGoogleTokenToBackend(user, idToken);

      // Save auth data locally
      await _saveAuthData(result);

      // Store Google sign-in status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_google_signin', true);
      await prefs.setString('firebase_uid', user.uid);

      debugPrint('✓ Google Sign-In completed successfully!');

      return result;
    } on PlatformException catch (e) {
      debugPrint('✗ Platform Exception: ${e.code} - ${e.message}');

      if (e.code == 'sign_in_failed') {
        if (e.message?.contains('10') == true) {
          throw Exception(
            'Configuration Error (Code 10):\n'
            'Please contact support with this error.\n'
            'Error: Missing or invalid SHA-1 fingerprint.',
          );
        }
      }

      await _cleanupGoogleSignIn();
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('✗ Firebase Auth Exception: ${e.code}');

      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
          'An account already exists with this email.\n'
          'Please sign in using your previous method.',
        );
      }

      await _cleanupGoogleSignIn();
      rethrow;
    } catch (e) {
      debugPrint('✗ Unexpected error: $e');
      await _cleanupGoogleSignIn();
      rethrow;
    }
  }

  /// Check if user is signed in with Google
  Future<bool> isGoogleSignedIn() async {
    try {
      final GoogleSignInAccount? googleUser = googleSignIn.currentUser;
      final User? firebaseUser = firebaseAuth.currentUser;
      final isSignedIn = googleUser != null && firebaseUser != null;
      debugPrint('Google signed in status: $isSignedIn');
      if (isSignedIn) {
        debugPrint('  Google User: ${googleUser!.email}');
        debugPrint('  Firebase User: ${firebaseUser!.email}');
      }
      return isSignedIn;
    } catch (e) {
      debugPrint('Error checking Google sign-in status: $e');
      return false;
    }
  }

  /// Get current Firebase user
  User? getCurrentFirebaseUser() {
    final user = firebaseAuth.currentUser;
    debugPrint('Current Firebase user: ${user?.email ?? 'null'}');
    return user;
  }

  /// Sign out from Google and Firebase
  Future<void> signOutFromGoogle() async {
    debugPrint('Signing out from Google and Firebase...');
    await _cleanupGoogleSignIn();
    debugPrint('Sign out completed');
  }

  /// Forgot password
  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> data) async {
    debugPrint(
      'Forgot password request for: ${data['email'] ?? data['phone']}',
    );
    try {
      final response = await dioClient.post(
        ApiConstants.forgotPassword,
        data: data,
      );
      final result = _handleResponse(response);
      debugPrint('Forgot password request successful');
      return result;
    } on DioException catch (e) {
      debugPrint('Forgot password request failed: ${e.message}');
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    debugPrint('Reset password attempt');
    try {
      final response = await dioClient.post(
        ApiConstants.resetPassword,
        data: data,
      );
      final result = _handleResponse(response);
      debugPrint('Reset password successful');
      return result;
    } on DioException catch (e) {
      debugPrint('Reset password failed: ${e.message}');
      throw ErrorHandler.handleDioError(e);
    }
  }
}