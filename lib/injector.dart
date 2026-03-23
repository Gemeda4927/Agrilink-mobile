import 'package:agrilink/features/cart/data/repository/cartRemoteDataSourceImpl.dart';
import 'package:agrilink/features/chat/data/repository/chat_repository_impl.dart';
import 'package:agrilink/features/chat/data/services/chat_service.dart';
import 'package:agrilink/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrilink/features/chat/domain/usecases/chat_usecases.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:agrilink/features/payment/data/repository/checkout_repository_impl.dart';
import 'package:agrilink/features/payment/data/service/checkout_service.dart';
import 'package:agrilink/features/payment/domain/repositories/checkout_repository.dart';
import 'package:agrilink/features/payment/domain/usecases/checkout_usecase.dart';
import 'package:agrilink/features/product/data/repository/product_repo_imp.dart';
import 'package:agrilink/features/product/data/services/product_service.dart';
import 'package:agrilink/features/product/domain/repository/product_repository.dart';
import 'package:agrilink/features/product/domain/usecases/get_products.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';
import 'package:agrilink/features/profile/data/repository/profile_repository_impl.dart';
import 'package:agrilink/features/profile/data/services/profile_service.dart';
import 'package:agrilink/features/profile/domain/repository/profile_repository.dart';
import 'package:agrilink/features/profile/domain/usecases/profile_usecases.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';
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
  // ================= CHAT FEATURE ===================
  // ==================================================

  // Chat Service
  sl.registerSingleton<ChatService>(ChatService(dioClient: sl<DioClient>()));

  // Chat Repository
  sl.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(chatService: sl<ChatService>()),
  );

  // Chat Use Cases
  sl.registerSingleton<FetchConversations>(
    FetchConversations(sl<ChatRepository>()),
  );
  sl.registerSingleton<FetchMessages>(FetchMessages(sl<ChatRepository>()));
  sl.registerSingleton<SendMessage>(SendMessage(sl<ChatRepository>()));
  sl.registerSingleton<ConnectSocket>(ConnectSocket(sl<ChatRepository>()));
  sl.registerSingleton<DisconnectSocket>(
    DisconnectSocket(sl<ChatRepository>()),
  );
  sl.registerSingleton<JoinConversation>(
    JoinConversation(sl<ChatRepository>()),
  );
  sl.registerSingleton<ListenForMessages>(
    ListenForMessages(sl<ChatRepository>()),
  );
  sl.registerSingleton<GetOrCreateConversation>(
    GetOrCreateConversation(sl<ChatRepository>()),
  );

  // Chat Bloc
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      fetchConversations: sl<FetchConversations>(),
      fetchMessages: sl<FetchMessages>(),
      sendMessage: sl<SendMessage>(),
      connectSocket: sl<ConnectSocket>(),
      disconnectSocket: sl<DisconnectSocket>(),
      joinConversation: sl<JoinConversation>(),
      listenForMessages: sl<ListenForMessages>(),
      getOrCreateConversation: sl<GetOrCreateConversation>(),
    ),
  );

  // ==================================================
  // ================= PRODUCT FEATURE ================
  // ==================================================

  // Product Service
  sl.registerSingleton<ProductService>(
    ProductService(dioClient: sl<DioClient>()),
  );

  // Product Repository
  sl.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(sl<ProductService>()),
  );

  // Product Use Cases
  sl.registerSingleton<GetProducts>(GetProducts(sl<ProductRepository>()));

  // Product Bloc
  sl.registerFactory<ProductBloc>(() => ProductBloc(sl<GetProducts>()));

  // ==================================================
  // ================= CART FEATURE ===================
  // ==================================================

  // Cart Service
  sl.registerSingleton<CartService>(CartService(sl<DioClient>()));

  // Cart Repository
  sl.registerSingleton<CartRepository>(CartRepositoryImpl(sl<CartService>()));

  // Cart Use Cases
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
  // ================= CHECKOUT FEATURE ===============
  // ==================================================

  // Checkout Service
  sl.registerSingleton<CheckoutService>(CheckoutService(sl<DioClient>()));

  // Checkout Repository
  sl.registerSingleton<CheckoutRepository>(
    CheckoutRepositoryImpl(sl<CheckoutService>()),
  );

  // Checkout Use Cases
  sl.registerSingleton<ProcessCheckoutUseCase>(
    ProcessCheckoutUseCase(sl<CheckoutRepository>()),
  );

  // ==================================================
  // ================= CART BLOC (Updated) ============
  // ==================================================

  // Cart Bloc with checkout dependencies
  sl.registerFactory<CartBloc>(
    () => CartBloc(
      getCartUseCase: sl<GetCartUseCase>(),
      addToCartUseCase: sl<AddToCartUseCase>(),
      updateCartUseCase: sl<UpdateCartUseCase>(),
      removeFromCartUseCase: sl<RemoveFromCartUseCase>(),
      processCheckoutUseCase: sl<ProcessCheckoutUseCase>(),
    ),
  );
}
