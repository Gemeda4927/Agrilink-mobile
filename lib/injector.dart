import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/core/network/token_manager.dart';

// ================= AUTH =================
import 'package:agrilink/features/auth/data/repository/auth_repository_impl.dart';
import 'package:agrilink/features/auth/data/service/auth_service.dart';
import 'package:agrilink/features/auth/domain/usecase/auth_usecases.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';

// ================= CATEGORY =================
import 'package:agrilink/features/category/data/service/category_service.dart';
import 'package:agrilink/features/category/data/repository/category_repository_impl.dart';

import 'package:agrilink/features/category/domain/usecases/get_categories.dart';
import 'package:agrilink/features/category/domain/usecases/get_subcategories.dart';

import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  // ================= FIREBASE =================
  await Firebase.initializeApp();

  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());

  // ================= CORE =================
  final tokenManager = await TokenManager.getInstance();

  sl.registerSingleton<TokenManager>(tokenManager);

  sl.registerSingleton<DioClient>(
    DioClient(tokenManager: sl<TokenManager>()),
  );

  // ==================================================
  // ================= AUTH FEATURE ===================
  // ==================================================

  // -------- Auth Service --------
  sl.registerSingleton<AuthService>(
    AuthService(
      dioClient: sl<DioClient>(),
      firebaseAuth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  // -------- Auth Repository --------
  sl.registerSingleton<AuthRepositoryImpl>(
    AuthRepositoryImpl(
      authService: sl<AuthService>(),
      tokenManager: sl<TokenManager>(),
    ),
  );

  // -------- Auth UseCases --------
  sl.registerSingleton<SignInUseCase>(
    SignInUseCase(sl<AuthRepositoryImpl>()),
  );

  sl.registerSingleton<SignUpUseCase>(
    SignUpUseCase(sl<AuthRepositoryImpl>()),
  );

  sl.registerSingleton<VerifyOtpUseCase>(
    VerifyOtpUseCase(sl<AuthRepositoryImpl>()),
  );

  sl.registerSingleton<GoogleSignInUseCase>(
    GoogleSignInUseCase(sl<AuthRepositoryImpl>()),
  );

  sl.registerSingleton<ForgotPasswordUseCase>(
    ForgotPasswordUseCase(sl<AuthRepositoryImpl>()),
  );

  sl.registerSingleton<ResetPasswordUseCase>(
    ResetPasswordUseCase(sl<AuthRepositoryImpl>()),
  );

  // -------- Auth Bloc --------
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      signInUseCase: sl<SignInUseCase>(),
      signUpUseCase: sl<SignUpUseCase>(),
      verifyOtpUseCase: sl<VerifyOtpUseCase>(),
      googleSignInUseCase: sl<GoogleSignInUseCase>(),
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
    ),
  );

  // ==================================================
  // ================= CATEGORY FEATURE ===============
  // ==================================================

  // -------- Category Service --------
  sl.registerSingleton<CategoryService>(
    CategoryService(dioClient: sl<DioClient>()),
  );

  // -------- Category Repository --------
  sl.registerSingleton<CategoryRepositoryImpl>(
    CategoryRepositoryImpl(service: sl<CategoryService>()),
  );

  // -------- Category UseCases --------
  sl.registerSingleton<GetCategories>(
    GetCategories(sl<CategoryRepositoryImpl>()),
  );

  sl.registerSingleton<GetSubCategories>(
    GetSubCategories(sl<CategoryRepositoryImpl>()),
  );

  // -------- Category Bloc --------
  sl.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      sl<GetCategories>(),
      sl<GetSubCategories>(),
    ),
  );
}