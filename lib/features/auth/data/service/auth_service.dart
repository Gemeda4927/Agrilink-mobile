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

  /// SAVE USER + TOKEN
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

  /// SIGNUP
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

  /// VERIFY OTP
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

  /// SIGNIN
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

  /// CHECK GOOGLE PLAY SERVICES
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

  /// GOOGLE SIGNIN - IMPROVED VERSION
  Future<Map<String, dynamic>> signInWithGoogle() async {
    debugPrint('=========================================');
    debugPrint('Starting Google Sign-In process...');
    debugPrint('=========================================');

    try {
      // Check Google Play Services
      final playServicesAvailable = await _checkGooglePlayServices();
      if (!playServicesAvailable) {
        debugPrint('Google Play Services not available');
        throw Exception(
          'Google Play Services not available. Please update Google Play Services.',
        );
      }

      // Check if already signed in
      final GoogleSignInAccount? existingUser = googleSignIn.currentUser;
      if (existingUser != null) {
        debugPrint('Existing Google user found: ${existingUser.email}');
        debugPrint('Signing out existing user...');
        await googleSignIn.signOut();
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Existing user signed out');
      }

      // Sign in with Google
      debugPrint('Prompting Google Sign-In dialog...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Google sign-in cancelled by user');
        throw Exception('Google sign-in cancelled by user');
      }

      debugPrint('✓ Google user signed in successfully');
      debugPrint('  Email: ${googleUser.email}');
      debugPrint('  Display Name: ${googleUser.displayName}');
      debugPrint('  ID: ${googleUser.id}');

      // Get authentication details
      debugPrint('Getting Google authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        debugPrint('✗ Failed to get ID token from Google');
        throw Exception('Failed to get ID token from Google');
      }

      debugPrint('✓ Google authentication successful');
      debugPrint(
        '  Access Token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}',
      );
      debugPrint(
        '  ID Token: ${googleAuth.idToken != null ? 'Present (${googleAuth.idToken!.length} chars)' : 'Missing'}',
      );

      // Create Firebase credential
      debugPrint('Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('✓ Firebase credential created');

      // Sign in to Firebase
      debugPrint('Signing in to Firebase...');
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        debugPrint('✗ Firebase user is null after authentication');
        throw Exception('Failed to authenticate with Firebase - user is null');
      }

      debugPrint('✓ Firebase authentication successful');
      debugPrint('  User UID: ${user.uid}');
      debugPrint('  User Email: ${user.email}');
      debugPrint('  Email Verified: ${user.emailVerified}');
      debugPrint('  Display Name: ${user.displayName}');

      // Send token to backend
      debugPrint('Sending authentication to backend...');
      final result = await _sendGoogleTokenToBackend(user);

      debugPrint('=========================================');
      debugPrint('✓ Google Sign-In completed successfully!');
      debugPrint('=========================================');

      return result;
    } on PlatformException catch (e) {
      debugPrint('=========================================');
      debugPrint('✗ Google Sign-In Platform Exception');
      debugPrint('  Code: ${e.code}');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Details: ${e.details}');
      debugPrint('=========================================');

      if (e.code == 'sign_in_failed') {
        if (e.message?.contains('10') == true) {
          throw Exception(
            'Google Sign-In configuration error (Code 10).\n'
            'Please ensure:\n'
            '1. SHA-1 fingerprint is added to Firebase Console\n'
            '2. Google Services JSON file is correct\n'
            '3. OAuth client ID is properly configured',
          );
        } else if (e.message?.contains('12500') == true) {
          throw Exception(
            'Google Sign-In failed. Please check your internet connection.',
          );
        } else {
          throw Exception('Google Sign-In failed: ${e.message}');
        }
      }
      await _cleanupGoogleSignIn();
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('=========================================');
      debugPrint('✗ Firebase Auth Exception');
      debugPrint('  Code: ${e.code}');
      debugPrint('  Message: ${e.message}');
      debugPrint('=========================================');

      if (e.code == 'account-exists-with-different-credential') {
        throw Exception(
          'An account already exists with the same email but different sign-in method.',
        );
      } else if (e.code == 'invalid-credential') {
        throw Exception('Invalid Google credential. Please try again.');
      }
      await _cleanupGoogleSignIn();
      rethrow;
    } catch (e) {
      debugPrint('=========================================');
      debugPrint('✗ Google Sign-In Unexpected Error');
      debugPrint('  Error: $e');
      debugPrint('  RuntimeType: ${e.runtimeType}');
      debugPrint('=========================================');
      await _cleanupGoogleSignIn();
      rethrow;
    }
  }

  /// SEND GOOGLE TOKEN TO BACKEND - IMPROVED VERSION
  Future<Map<String, dynamic>> _sendGoogleTokenToBackend(User user) async {
    debugPrint('-----------------------------------------');
    debugPrint('Sending Google token to backend...');
    debugPrint('-----------------------------------------');

    try {
      // Force token refresh to ensure it's valid
      debugPrint('Refreshing Firebase token...');
      await user.getIdToken(true);
      final idToken = await user.getIdToken();

      if (idToken == null) {
        debugPrint('✗ Failed to get Firebase ID token');
        throw Exception('Failed to get Firebase ID token');
      }

      debugPrint('✓ Firebase token obtained successfully');
      debugPrint('  Token length: ${idToken.length} chars');

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

      final result = _handleResponse(response);
      debugPrint('✓ Backend response received');
      debugPrint('  Status Code: ${response.statusCode}');

      // Verify backend response has required fields
      if (result['token'] == null || result['user'] == null) {
        debugPrint('✗ Invalid backend response: missing token or user data');
        debugPrint('  Response keys: ${result.keys}');
        throw Exception('Invalid response from backend');
      }

      debugPrint('✓ Backend response valid');
      debugPrint('  Token present: ${result['token'] != null}');
      debugPrint('  User data present: ${result['user'] != null}');
      debugPrint('  User role: ${result['user']?['role'] ?? 'Unknown'}');

      // Save user data locally
      debugPrint('Saving auth data locally...');
      await _saveAuthData(result);

      // Also save Firebase UID separately if needed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_uid', user.uid);
      debugPrint('✓ Firebase UID saved locally');
      debugPrint('-----------------------------------------');
      debugPrint('✓ Backend authentication successful');
      debugPrint('-----------------------------------------');

      return result;
    } on DioException catch (e) {
      debugPrint('-----------------------------------------');
      debugPrint('✗ Backend API call failed');
      debugPrint('  Type: ${e.type}');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Status Code: ${e.response?.statusCode}');
      debugPrint('  Response: ${e.response?.data}');
      debugPrint('-----------------------------------------');
      await _cleanupGoogleSignIn();
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      debugPrint('-----------------------------------------');
      debugPrint('✗ Unexpected error in backend communication');
      debugPrint('  Error: $e');
      debugPrint('-----------------------------------------');
      await _cleanupGoogleSignIn();
      rethrow;
    }
  }

  /// CHECK IF USER IS SIGNED IN WITH GOOGLE
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

  /// GET CURRENT FIREBASE USER
  User? getCurrentFirebaseUser() {
    final user = firebaseAuth.currentUser;
    debugPrint('Current Firebase user: ${user?.email ?? 'null'}');
    return user;
  }

  /// SIGN OUT FROM GOOGLE AND FIREBASE
  Future<void> signOutFromGoogle() async {
    debugPrint('Signing out from Google and Firebase...');
    await _cleanupGoogleSignIn();
    debugPrint('Sign out completed');
  }

  /// CLEANUP GOOGLE SIGN IN
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

  /// FORGOT PASSWORD
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

  /// RESET PASSWORD
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

  /// HANDLE RESPONSE
  Map<String, dynamic> _handleResponse(Response response) {
    debugPrint('Handling API response - Status code: ${response.statusCode}');
    if (response.data is Map<String, dynamic>) {
      debugPrint('Response is valid Map');
      return response.data as Map<String, dynamic>;
    }
    debugPrint('Response is not a Map, returning default message');
    return {'message': response.data?.toString() ?? ''};
  }
}
