import 'package:get_it/get_it.dart';
import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/core/network/token_manager.dart';
import 'package:agrilink/features/auth/data/repository/auth_repository_impl.dart';
import 'package:agrilink/features/auth/data/service/auth_service.dart';
import 'package:agrilink/features/auth/domain/usecase/auth_usecases.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  // --- Core ---
  final tokenManager = await TokenManager.getInstance();
  sl.registerSingleton<TokenManager>(tokenManager);
  
  sl.registerSingleton<DioClient>(
    DioClient(tokenManager: sl<TokenManager>()),
  );

  // --- Services ---
  sl.registerSingleton<AuthService>(
    AuthService(dioClient: sl<DioClient>()),
  );

  // --- Repository ---
  sl.registerSingleton<AuthRepositoryImpl>(
    AuthRepositoryImpl(
      authService: sl<AuthService>(),
      tokenManager: sl<TokenManager>(),
    ),
  );

  // --- Use Cases ---
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

  // --- Bloc ---
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
}