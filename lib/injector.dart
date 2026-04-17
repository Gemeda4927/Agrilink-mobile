import 'package:agrilink/features/cart/data/repository/cartRemoteDataSourceImpl.dart';
import 'package:agrilink/features/chat/data/repository/chat_repository_impl.dart';
import 'package:agrilink/features/chat/data/services/chat_service.dart';
import 'package:agrilink/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrilink/features/chat/domain/usecases/chat_usecases.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:agrilink/features/domain/payment/data/repository/checkout_repository_impl.dart';
import 'package:agrilink/features/domain/payment/data/service/checkout_service.dart';
import 'package:agrilink/features/domain/payment/domain/repositories/checkout_repository.dart';
import 'package:agrilink/features/domain/payment/domain/usecases/checkout_usecase.dart';
import 'package:agrilink/features/order/data/repository/order_repository_impl.dart';
import 'package:agrilink/features/order/data/services/order_service.dart';
import 'package:agrilink/features/order/domain/repositories/order_repository.dart';
import 'package:agrilink/features/order/domain/usecases/get_my_orders.dart';
import 'package:agrilink/features/order/presentation/bloc/order_bloc.dart';
import 'package:agrilink/features/product/data/repository/product_repo_imp.dart';
import 'package:agrilink/features/product/data/services/product_service.dart';
import 'package:agrilink/features/product/domain/repository/product_repository.dart';
import 'package:agrilink/features/product/domain/usecases/create_product.dart';
import 'package:agrilink/features/product/domain/usecases/get_products.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';
import 'package:agrilink/features/profile/data/repository/profile_repository_impl.dart';
import 'package:agrilink/features/profile/data/services/profile_service.dart';
import 'package:agrilink/features/profile/domain/repository/profile_repository.dart';
import 'package:agrilink/features/profile/domain/usecases/profile_usecases.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:agrilink/features/recommendation/data/repository/chat_repository_impl.dart';
import 'package:agrilink/features/recommendation/data/service/chat_service.dart';
import 'package:agrilink/features/recommendation/domain/repository/chat_repository.dart';
import 'package:agrilink/features/recommendation/domain/usecase/send_chat_message_usecase.dart';
import 'package:agrilink/features/recommendation/presentation/bloc/chat_bloc.dart';
import 'package:agrilink/features/role_request/domain/usecases/create_role_request_usecase.dart';
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

// ================= ROLE REQUEST =================
import 'package:agrilink/features/role_request/data/repositories/role_request_repository_impl.dart';
import 'package:agrilink/features/role_request/data/service/role_request_service.dart';
import 'package:agrilink/features/role_request/domain/repositories/role_request_repository.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_bloc.dart';

// ================= CART =================
import 'package:agrilink/features/cart/data/service/cart_service.dart';
import 'package:agrilink/features/cart/domain/repositories/cart_repository.dart';
import 'package:agrilink/features/cart/domain/usecases/cart_usecases.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:logger/logger.dart';

// ================= LOCALIZATION =================
import 'package:agrilink/core/localization/language_bloc.dart';
import 'package:agrilink/core/localization/locale_provider.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  // ================= FIREBASE =================
  await Firebase.initializeApp();
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());

  // ================= CORE LOGGER =================
  sl.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    ),
  );

  // ================= CORE =================
  final tokenManager = await TokenManager.getInstance();
  sl.registerSingleton<TokenManager>(tokenManager);
  sl.registerSingleton<DioClient>(DioClient(tokenManager: sl<TokenManager>()));

  // ================= LOCALIZATION =================
  // Register LocaleProvider as a lazy singleton
  sl.registerLazySingleton<LocaleProvider>(() => LocaleProvider());

  // Register LanguageBloc as a lazy singleton (persists across app lifecycle)
  // Using registerLazySingleton ensures the same instance is used throughout the app
  sl.registerLazySingleton<LanguageBloc>(() => LanguageBloc());

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
  // ================= ROLE REQUEST FEATURE ==========
  // ==================================================
  sl.registerSingleton<RoleRequestService>(RoleRequestService(sl<DioClient>()));

  sl.registerSingleton<RoleRequestRepository>(
    RoleRequestRepositoryImpl(sl<RoleRequestService>()),
  );

  sl.registerSingleton<RoleRequestUseCases>(
    RoleRequestUseCases(sl<RoleRequestRepository>()),
  );

  sl.registerFactory<RoleRequestBloc>(
    () => RoleRequestBloc(sl<RoleRequestUseCases>()),
  );

  // ==================================================
  // ================= PROFILE FEATURE ================
  // ==================================================
  sl.registerSingleton<ProfileService>(
    ProfileService(dioClient: sl<DioClient>()),
  );

  sl.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(profileService: sl<ProfileService>()),
  );

  sl.registerSingleton<CreateProfileUseCase>(
    CreateProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerSingleton<UpdateProfileUseCase>(
    UpdateProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerSingleton<GetProfileUseCase>(
    GetProfileUseCase(sl<ProfileRepository>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      createUseCase: sl<CreateProfileUseCase>(),
      updateUseCase: sl<UpdateProfileUseCase>(),
      getUseCase: sl<GetProfileUseCase>(),
    ),
  );

  // ==================================================
  // ================= PRODUCT FEATURE ================
  // ==================================================
  sl.registerSingleton<ProductService>(
    ProductService(dioClient: sl<DioClient>()),
  );

  sl.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(sl<ProductService>()),
  );

  sl.registerSingleton<GetProducts>(GetProducts(sl<ProductRepository>()));
  sl.registerSingleton<CreateProduct>(CreateProduct(sl<ProductRepository>()));

  sl.registerFactory<ProductBloc>(
    () => ProductBloc(sl<GetProducts>(), sl<CreateProduct>()),
  );

  // ==================================================
  // ================= CART FEATURE ===================
  // ==================================================
  sl.registerSingleton<CartService>(CartService(sl<DioClient>()));

  sl.registerSingleton<CartRepository>(CartRepositoryImpl(sl<CartService>()));

  sl.registerSingleton<GetCartUseCase>(GetCartUseCase(sl<CartRepository>()));

  sl.registerSingleton<AddToCartUseCase>(
    AddToCartUseCase(sl<CartRepository>()),
  );

  sl.registerSingleton<UpdateCartUseCase>(
    UpdateCartUseCase(sl<CartRepository>()),
  );

  sl.registerSingleton<RemoveFromCartUseCase>(
    RemoveFromCartUseCase(sl<CartRepository>()),
  );

  // ==================================================
  // ================= ORDER FEATURE ==================
  // ==================================================

  // SERVICE
  sl.registerLazySingleton<OrderService>(
    () => OrderService(dioClient: sl<DioClient>()),
  );

  // REPOSITORY
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(orderService: sl<OrderService>()),
  );

  // USE CASES
  sl.registerLazySingleton<GetMyOrdersUseCase>(
    () => GetMyOrdersUseCase(sl<OrderRepository>()),
  );

  // BLOC
  sl.registerFactory<OrderBloc>(
    () => OrderBloc(getMyOrdersUseCase: sl<GetMyOrdersUseCase>()),
  );

  // ==================================================
  // ================= CHECKOUT FEATURE ===============
  // ==================================================
  sl.registerSingleton<CheckoutService>(CheckoutService(sl<DioClient>()));

  sl.registerSingleton<CheckoutRepository>(
    CheckoutRepositoryImpl(sl<CheckoutService>()),
  );

  sl.registerSingleton<ProcessCheckoutUseCase>(
    ProcessCheckoutUseCase(sl<CheckoutRepository>()),
  );

  // ==================================================
  // ================= CART BLOC ======================
  // ==================================================
  sl.registerFactory<CartBloc>(
    () => CartBloc(
      getCartUseCase: sl<GetCartUseCase>(),
      addToCartUseCase: sl<AddToCartUseCase>(),
      updateCartUseCase: sl<UpdateCartUseCase>(),
      removeFromCartUseCase: sl<RemoveFromCartUseCase>(),
      processCheckoutUseCase: sl<ProcessCheckoutUseCase>(),
    ),
  );

  // ==================================================
  // ================= CHAT FEATURE ===================
  // ==================================================

  // SERVICE
  sl.registerLazySingleton<ChatService>(
    () => ChatService(logger: sl<Logger>(), dioClient: sl<DioClient>()),
  );

  // REPOSITORY
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(chatService: sl<ChatService>()),
  );

  // USE CASES
  sl.registerLazySingleton<ChatUseCases>(
    () => ChatUseCases(sl<ChatRepository>()),
  );

  // BLOC
  sl.registerFactory<ChatBloc>(() => ChatBloc(useCases: sl<ChatUseCases>()));

  // ==================================================
  // ========== RECOMMENDATION CHAT V2 FEATURE ========
  // ==================================================

  // SERVICE
  sl.registerLazySingleton<ChatService2>(
    () => ChatService2(dioClient: sl<DioClient>()),
  );

  // REPOSITORY
  sl.registerLazySingleton<ChatRepository2>(
    () => ChatRepositoryImpl2(service: sl<ChatService2>()),
  );

  // USE CASE
  sl.registerLazySingleton<SendChatMessageUseCase2>(
    () => SendChatMessageUseCase2(sl<ChatRepository2>()),
  );

  // BLOC
  sl.registerFactory<ChatBloc2>(
    () => ChatBloc2(sendMessageUseCase: sl<SendChatMessageUseCase2>()),
  );
}

// ================= HELPER GETTERS FOR LOCALIZATION =================
// Optional: Add helper methods to easily access localization dependencies

/// Get the LocaleProvider instance from GetIt
LocaleProvider getLocaleProvider() => sl<LocaleProvider>();

/// Get the LanguageBloc instance from GetIt
LanguageBloc getLanguageBloc() => sl<LanguageBloc>();

/// Alternative: Extension on GetIt for cleaner syntax
extension GetItLocalization on GetIt {
  LocaleProvider get localeProvider => get<LocaleProvider>();
  LanguageBloc get languageBloc => get<LanguageBloc>();
}
