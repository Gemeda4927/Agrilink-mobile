import 'package:agrilink/features/product/data/repository/product_repo_imp.dart';
import 'package:agrilink/features/product/data/services/product_service.dart';
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

// ================= REGISTRATION =================
import 'package:agrilink/features/registration/data/services/registration_service.dart';
import 'package:agrilink/features/registration/data/repositories/registration_repository_impl.dart';
import 'package:agrilink/features/registration/domain/repositories/registration_repository.dart';
import 'package:agrilink/features/registration/domain/usecases/registration_usecases.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';

// ================= PRODUCT =================
import 'package:agrilink/features/product/domain/usecases/get_products.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  // ================= FIREBASE =================
  await Firebase.initializeApp();

  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());

  // ================= CORE =================
  final tokenManager = await TokenManager.getInstance();
  sl.registerSingleton<TokenManager>(tokenManager);

  sl.registerSingleton<DioClient>(DioClient(tokenManager: sl<TokenManager>()));

  // ==================================================
  // ================= AUTH FEATURE ===================
  // ==================================================
  sl.registerSingleton<AuthService>(
    AuthService(
      dioClient: sl<DioClient>(),
      firebaseAuth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );

  sl.registerSingleton<AuthRepositoryImpl>(
    AuthRepositoryImpl(
      authService: sl<AuthService>(),
      tokenManager: sl<TokenManager>(),
    ),
  );

  sl.registerSingleton<SignInUseCase>(SignInUseCase(sl<AuthRepositoryImpl>()));
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase(sl<AuthRepositoryImpl>()));
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
  sl.registerSingleton<CategoryService>(
    CategoryService(dioClient: sl<DioClient>()),
  );

  sl.registerSingleton<CategoryRepositoryImpl>(
    CategoryRepositoryImpl(service: sl<CategoryService>()),
  );

  sl.registerSingleton<GetCategories>(
    GetCategories(sl<CategoryRepositoryImpl>()),
  );

  sl.registerSingleton<GetSubCategories>(
    GetSubCategories(sl<CategoryRepositoryImpl>()),
  );

  sl.registerFactory<CategoryBloc>(
    () => CategoryBloc(sl<GetCategories>(), sl<GetSubCategories>()),
  );

  // ==================================================
  // ================= REGISTRATION FEATURE ===========
  // ==================================================
  sl.registerSingleton<RegistrationService>(
    RegistrationService(dioClient: sl<DioClient>()),
  );

  sl.registerSingleton<RegistrationRepository>(
    RegistrationRepositoryImpl(sl<RegistrationService>()),
  );

  sl.registerSingleton<RegistrationUseCases>(
    RegistrationUseCases(sl<RegistrationRepository>()),
  );

  sl.registerFactory<RegistrationBloc>(
    () => RegistrationBloc(sl<RegistrationUseCases>()),
  );

  // ==================================================
  // ================= PRODUCT FEATURE ===============
  // ==================================================
  sl.registerSingleton<ProductService>(
    ProductService(dioClient: sl<DioClient>()),
  );

  sl.registerSingleton<ProductRepositoryImpl>(
    ProductRepositoryImpl(sl<ProductService>()),
  );

  sl.registerSingleton<GetProducts>(GetProducts(sl<ProductRepositoryImpl>()));

  sl.registerFactory<ProductBloc>(() => ProductBloc(sl<GetProducts>()));
}
