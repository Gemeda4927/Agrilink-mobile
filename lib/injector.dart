import 'package:agrilink/core/services/notification_service.dart';
import 'package:agrilink/features/cart/data/repository/cartRemoteDataSourceImpl.dart';
import 'package:agrilink/features/insight/data/services/marketService.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_bloc.dart';
import 'package:agrilink/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:agrilink/features/notification/data/services/notification_service.dart';
import 'package:agrilink/features/notification/domain/repositories/notification_repository.dart';
import 'package:agrilink/features/notification/domain/usecases/notification_usecases.dart';
import 'package:agrilink/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:agrilink/features/product/domain/usecases/delete_product.dart';
import 'package:agrilink/features/product/domain/usecases/get_my_products.dart';
import 'package:agrilink/features/product/domain/usecases/get_product_by_id.dart';
import 'package:agrilink/features/product/domain/usecases/get_products_by_category.dart';
import 'package:agrilink/features/product/domain/usecases/search_products.dart';
import 'package:agrilink/features/product/domain/usecases/update_product.dart';
import 'package:agrilink/features/role_request/domain/usecases/create_role_request_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import 'package:agrilink/core/network/dio_client.dart';
import 'package:agrilink/core/network/token_manager.dart';
import 'package:agrilink/core/localization/language_bloc.dart';
import 'package:agrilink/core/localization/locale_provider.dart';

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

// ================= PROFILE =================
import 'package:agrilink/features/profile/data/repository/profile_repository_impl.dart';
import 'package:agrilink/features/profile/data/services/profile_service.dart';
import 'package:agrilink/features/profile/domain/repository/profile_repository.dart';
import 'package:agrilink/features/profile/domain/usecases/profile_usecases.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';

// ================= PRODUCT =================
import 'package:agrilink/features/product/data/repository/product_repo_imp.dart';
import 'package:agrilink/features/product/data/services/product_service.dart';
import 'package:agrilink/features/product/domain/repository/product_repository.dart';
import 'package:agrilink/features/product/domain/usecases/create_product.dart';
import 'package:agrilink/features/product/domain/usecases/get_products.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';

// ================= CART & PAYMENT =================
import 'package:agrilink/features/cart/data/service/cart_service.dart';
import 'package:agrilink/features/cart/domain/repositories/cart_repository.dart';
import 'package:agrilink/features/cart/domain/usecases/cart_usecases.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';

// ================= ORDERS =================
import 'package:agrilink/features/order/data/repository/order_repository_impl.dart';
import 'package:agrilink/features/order/data/services/order_service.dart';
import 'package:agrilink/features/order/domain/repositories/order_repository.dart';
import 'package:agrilink/features/order/presentation/bloc/order_bloc.dart';

// ================= FARMER ORDERS =================
import 'package:agrilink/features/my_product/data/repositories/farmer_order_repository.dart';
import 'package:agrilink/features/my_product/data/services/farmer_order_service.dart';
import 'package:agrilink/features/my_product/domain/repositories/i_farmer_order_repository.dart';
import 'package:agrilink/features/my_product/domain/usecases/farmer_order_usecases.dart';

// ================= CHAT =================
import 'package:agrilink/features/chat/data/repository/chat_repository_impl.dart';
import 'package:agrilink/features/chat/data/services/chat_service.dart';
import 'package:agrilink/features/chat/domain/repositories/chat_repository.dart';
import 'package:agrilink/features/chat/domain/usecases/chat_usecases.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_bloc.dart';

// ================= RECOMMENDATION CHAT =================
import 'package:agrilink/features/recommendation/data/repository/chat_repository_impl.dart';
import 'package:agrilink/features/recommendation/data/service/chat_service.dart';
import 'package:agrilink/features/recommendation/domain/repository/chat_repository.dart';
import 'package:agrilink/features/recommendation/domain/usecase/send_chat_message_usecase.dart';
import 'package:agrilink/features/recommendation/presentation/bloc/chat_bloc.dart';

// ================= MARKET INSIGHT =================
import 'package:agrilink/features/insight/data/repository/market_repository_impl.dart';
import 'package:agrilink/features/insight/domain/repository/i_market_repository.dart';
import 'package:agrilink/features/insight/domain/usecase/market_usecases.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'features/order/domain/usecases/get_my_orders.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  // ==================================================
  // ================= INITIALIZE ASYNC FIRST =========
  // ==================================================

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SharedPreferences FIRST (Critical for RoleRequest)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Initialize TokenManager
  final tokenManager = await TokenManager.getInstance();
  sl.registerSingleton<TokenManager>(tokenManager);

  // ==================================================
  // ================= FIREBASE SERVICES ==============
  // ==================================================
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());

  // ==================================================
  // ================= CORE ===========================
  // ==================================================
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

  sl.registerSingleton<DioClient>(DioClient(tokenManager: sl<TokenManager>()));

  // ==================================================
  // ================= LOCALIZATION ===================
  // ==================================================
  sl.registerLazySingleton<LocaleProvider>(() => LocaleProvider());
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
  // SharedPreferences is already registered above ✓
  sl.registerSingleton<RoleRequestService>(RoleRequestService(sl<DioClient>()));

  sl.registerSingleton<RoleRequestRepository>(
    RoleRequestRepositoryImpl(sl<RoleRequestService>()),
  );

  sl.registerSingleton<RoleRequestUseCases>(
    RoleRequestUseCases(sl<RoleRequestRepository>()),
  );

  sl.registerFactory<RoleRequestBloc>(
    () => RoleRequestBloc(useCases: sl<RoleRequestUseCases>()),
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

  // ==================================================
  // ================= CORE SERVICES ==================
  // ==================================================

  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // ==================================================
  // ================= NOTIFICATION FEATURE ===========
  // ==================================================

  sl.registerLazySingleton<ApiNotificationService>(
    () => ApiNotificationService(
      dioClient: sl<DioClient>(),
      prefs: sl<SharedPreferences>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationService: sl<ApiNotificationService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<GetNewNotificationsUseCase>(
    () => GetNewNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<GetUnreadNotificationsUseCase>(
    () => GetUnreadNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<MarkAsReadUseCase>(
    () => MarkAsReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<MarkAllAsReadUseCase>(
    () => MarkAllAsReadUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<DeleteNotificationUseCase>(
    () => DeleteNotificationUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<DeleteAllNotificationsUseCase>(
    () => DeleteAllNotificationsUseCase(sl<NotificationRepository>()),
  );
  sl.registerLazySingleton<GetUnreadCountUseCase>(
    () => GetUnreadCountUseCase(sl<NotificationRepository>()),
  );

  // BLoC
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotificationsUseCase: sl<GetNotificationsUseCase>(),
      getNewNotificationsUseCase: sl<GetNewNotificationsUseCase>(),
      getUnreadCountUseCase: sl<GetUnreadCountUseCase>(),
      markAsReadUseCase: sl<MarkAsReadUseCase>(),
      markAllAsReadUseCase: sl<MarkAllAsReadUseCase>(),
      deleteNotificationUseCase: sl<DeleteNotificationUseCase>(),
      deleteAllNotificationsUseCase: sl<DeleteAllNotificationsUseCase>(),
    ),
  );

  sl.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(sl<ProductService>()),
  );

  sl.registerSingleton<GetProducts>(GetProducts(sl<ProductRepository>()));
  sl.registerSingleton<CreateProduct>(CreateProduct(sl<ProductRepository>()));
  sl.registerSingleton<GetMyProductsUseCase>(
    GetMyProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerSingleton<GetProductByIdUseCase>(
    GetProductByIdUseCase(sl<ProductRepository>()),
  );
  sl.registerSingleton<UpdateProductUseCase>(
    UpdateProductUseCase(sl<ProductRepository>()),
  );
  sl.registerSingleton<DeleteProductUseCase>(
    DeleteProductUseCase(sl<ProductRepository>()),
  );
  sl.registerSingleton<GetProductsByCategoryUseCase>(
    GetProductsByCategoryUseCase(sl<ProductRepository>()),
  );
  sl.registerSingleton<SearchProductsUseCase>(
    SearchProductsUseCase(sl<ProductRepository>()),
  );

  sl.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProducts: sl<GetProducts>(),
      createProduct: sl<CreateProduct>(),
      getMyProducts: sl<GetMyProductsUseCase>(),
      getProductById: sl<GetProductByIdUseCase>(),
      updateProduct: sl<UpdateProductUseCase>(),
      deleteProduct: sl<DeleteProductUseCase>(),
      getProductsByCategory: sl<GetProductsByCategoryUseCase>(),
      searchProducts: sl<SearchProductsUseCase>(),
    ),
  );

  // ==================================================
  // ================= CART & PAYMENT FEATURE =========
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
  sl.registerSingleton<ClearCartUseCase>(
    ClearCartUseCase(sl<CartRepository>()),
  );
  sl.registerSingleton<GetCartTotalUseCase>(
    GetCartTotalUseCase(sl<CartRepository>()),
  );
  sl.registerSingleton<CheckoutUseCase>(CheckoutUseCase(sl<CartRepository>()));
  sl.registerSingleton<VerifyPaymentUseCase>(
    VerifyPaymentUseCase(sl<CartRepository>()),
  );
  sl.registerSingleton<CheckPaymentStatusUseCase>(
    CheckPaymentStatusUseCase(sl<CartRepository>()),
  );
  sl.registerSingleton<CancelOrderUseCase>(
    CancelOrderUseCase(sl<CartRepository>()),
  );
  sl.registerSingleton<GetOrderDetailsUseCase>(
    GetOrderDetailsUseCase(sl<CartRepository>()),
  );

  sl.registerFactory<CartBloc>(
    () => CartBloc(
      getCartUseCase: sl<GetCartUseCase>(),
      addToCartUseCase: sl<AddToCartUseCase>(),
      updateCartUseCase: sl<UpdateCartUseCase>(),
      removeFromCartUseCase: sl<RemoveFromCartUseCase>(),
      clearCartUseCase: sl<ClearCartUseCase>(),
      checkoutUseCase: sl<CheckoutUseCase>(),
      verifyPaymentUseCase: sl<VerifyPaymentUseCase>(),
    ),
  );

  // ==================================================
  // ================= ORDER FEATURE ==================
  // ==================================================
  sl.registerLazySingleton<OrderService>(
    () => OrderService(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(orderService: sl<OrderService>()),
  );

  // Register all Order Use Cases with 2 suffix
  sl.registerLazySingleton<GetMyOrdersUseCase2>(
    () => GetMyOrdersUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetFarmerOrdersUseCase2>(
    () => GetFarmerOrdersUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetPendingFarmerOrdersUseCase2>(
    () => GetPendingFarmerOrdersUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetOrderByIdUseCase2>(
    () => GetOrderByIdUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetFarmerOrderByIdUseCase2>(
    () => GetFarmerOrderByIdUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<UpdateOrderStatusUseCase2>(
    () => UpdateOrderStatusUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<AcceptOrderUseCase2>(
    () => AcceptOrderUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<RejectOrderUseCase2>(
    () => RejectOrderUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<MarkAsDeliveredUseCase2>(
    () => MarkAsDeliveredUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<CancelOrderUseCase2>(
    () => CancelOrderUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<CompleteOrderUseCase2>(
    () => CompleteOrderUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<CheckoutUseCase2>(
    () => CheckoutUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<VerifyOrderUseCase2>(
    () => VerifyOrderUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetOrderCountsUseCase2>(
    () => GetOrderCountsUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetFarmerOrderCountsUseCase2>(
    () => GetFarmerOrderCountsUseCase2(sl<OrderRepository>()),
  );
  sl.registerLazySingleton<GetOrdersByDateRangeUseCase2>(
    () => GetOrdersByDateRangeUseCase2(sl<OrderRepository>()),
  );

  // Register OrderBloc with all required use cases
  sl.registerFactory<OrderBloc>(
    () => OrderBloc(
      getMyOrdersUseCase: sl<GetMyOrdersUseCase2>(),
      getOrderByIdUseCase: sl<GetOrderByIdUseCase2>(),
      cancelOrderUseCase: sl<CancelOrderUseCase2>(),
      completeOrderUseCase: sl<CompleteOrderUseCase2>(),
      getOrderCountsUseCase: sl<GetOrderCountsUseCase2>(),
      getFarmerOrdersUseCase: sl<GetFarmerOrdersUseCase2>(),
      getPendingFarmerOrdersUseCase: sl<GetPendingFarmerOrdersUseCase2>(),
      getFarmerOrderByIdUseCase: sl<GetFarmerOrderByIdUseCase2>(),
      updateOrderStatusUseCase: sl<UpdateOrderStatusUseCase2>(),
      acceptOrderUseCase: sl<AcceptOrderUseCase2>(),
      rejectOrderUseCase: sl<RejectOrderUseCase2>(),
      markAsDeliveredUseCase: sl<MarkAsDeliveredUseCase2>(),
      getFarmerOrderCountsUseCase: sl<GetFarmerOrderCountsUseCase2>(),
      checkoutUseCase: sl<CheckoutUseCase2>(),
      verifyOrderUseCase: sl<VerifyOrderUseCase2>(),
    ),
  );

  // ==================================================
  // ================= FARMER ORDER FEATURE ===========
  // ==================================================
  sl.registerLazySingleton<FarmerOrderService>(
    () => FarmerOrderService(sl<DioClient>()),
  );
  sl.registerLazySingleton<IFarmerOrderRepository>(
    () => FarmerOrderRepository(sl<FarmerOrderService>()),
  );

  sl.registerLazySingleton<GetFarmerOrdersUseCase>(
    () => GetFarmerOrdersUseCase(sl<IFarmerOrderRepository>()),
  );
  sl.registerLazySingleton<GetPendingFarmerOrdersUseCase>(
    () => GetPendingFarmerOrdersUseCase(sl<IFarmerOrderRepository>()),
  );
  sl.registerLazySingleton<GetFarmerOrderByIdUseCase>(
    () => GetFarmerOrderByIdUseCase(sl<IFarmerOrderRepository>()),
  );
  sl.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(sl<IFarmerOrderRepository>()),
  );
  sl.registerLazySingleton<PatchProductUseCase>(
    () => PatchProductUseCase(sl<IFarmerOrderRepository>()),
  );

  // BLoC
  sl.registerFactory<FarmerOrderBloc>(
    () => FarmerOrderBloc(
      getFarmerOrdersUseCase: sl(),
      getPendingFarmerOrdersUseCase: sl(),
      getFarmerOrderByIdUseCase: sl(),
      updateOrderStatusUseCase: sl(),
      patchProductUseCase: sl(),
    ),
  );

  // ==================================================
  // ================= CHAT FEATURE ===================
  // ==================================================
  sl.registerLazySingleton<ChatService>(
    () => ChatService(logger: sl<Logger>(), dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(chatService: sl<ChatService>()),
  );
  sl.registerLazySingleton<ChatUseCases>(
    () => ChatUseCases(sl<ChatRepository>()),
  );
  sl.registerFactory<ChatBloc>(() => ChatBloc(useCases: sl<ChatUseCases>()));

  // ==================================================
  // ========== RECOMMENDATION CHAT V2 FEATURE ========
  // ==================================================
  sl.registerLazySingleton<ChatService2>(
    () => ChatService2(dioClient: sl<DioClient>()),
  );
  sl.registerLazySingleton<ChatRepository2>(
    () => ChatRepositoryImpl2(service: sl<ChatService2>()),
  );
  sl.registerLazySingleton<SendChatMessageUseCase2>(
    () => SendChatMessageUseCase2(sl<ChatRepository2>()),
  );
  sl.registerFactory<ChatBloc2>(
    () => ChatBloc2(sendMessageUseCase: sl<SendChatMessageUseCase2>()),
  );

  // ==================================================
  // ================= MARKET INSIGHT FEATURE =========
  // ==================================================

  // Register Service
  sl.registerLazySingleton<MarketService>(
    () => MarketService(dioClient: sl<DioClient>()),
  );

  // Register Repository
  sl.registerLazySingleton<IMarketRepository>(
    () => MarketRepositoryImpl(marketService: sl<MarketService>()),
  );

  // Register Use Cases - Grouped by feature
  void _registerMarketUseCases() {
    // Product Use Cases
    sl.registerLazySingleton<GetAllProductsUseCase>(
      () => GetAllProductsUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetPublicProductsUseCase>(
      () => GetPublicProductsUseCase(sl<IMarketRepository>()),
    );

    // Market Price CRUD Use Cases
    sl.registerLazySingleton<SubmitMarketPriceUseCase>(
      () => SubmitMarketPriceUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetAllMarketPricesUseCase>(
      () => GetAllMarketPricesUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetApprovedMarketPricesUseCase>(
      () => GetApprovedMarketPricesUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetMyMarketPricesUseCase>(
      () => GetMyMarketPricesUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetMarketPricesByWoredaUseCase>(
      () => GetMarketPricesByWoredaUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetMarketPricesByProductUseCase>(
      () => GetMarketPricesByProductUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetMarketPriceByIdUseCase>(
      () => GetMarketPriceByIdUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<UpdateMarketPriceUseCase>(
      () => UpdateMarketPriceUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<DeleteMarketPriceUseCase>(
      () => DeleteMarketPriceUseCase(sl<IMarketRepository>()),
    );

    // Moderation Use Cases (ADMIN/AGENT)
    sl.registerLazySingleton<ApproveMarketPriceUseCase>(
      () => ApproveMarketPriceUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<RejectMarketPriceUseCase>(
      () => RejectMarketPriceUseCase(sl<IMarketRepository>()),
    );

    // Statistics & Analytics Use Cases
    sl.registerLazySingleton<GetProductPriceStatisticsUseCase>(
      () => GetProductPriceStatisticsUseCase(sl<IMarketRepository>()),
    );
    sl.registerLazySingleton<GetRecentPriceAlertsUseCase>(
      () => GetRecentPriceAlertsUseCase(sl<IMarketRepository>()),
    );
  }

  // Register BLoC
  void _registerMarketBloc() {
    sl.registerFactory<MarketBloc>(
      () => MarketBloc(
        // Product Use Cases
        getAllProductsUseCase: sl<GetAllProductsUseCase>(),
        getPublicProductsUseCase: sl<GetPublicProductsUseCase>(),
        // Market Price Use Cases
        submitMarketPriceUseCase: sl<SubmitMarketPriceUseCase>(),
        getAllMarketPricesUseCase: sl<GetAllMarketPricesUseCase>(),
        getApprovedMarketPricesUseCase: sl<GetApprovedMarketPricesUseCase>(),
        getMyMarketPricesUseCase: sl<GetMyMarketPricesUseCase>(),
        getMarketPricesByWoredaUseCase: sl<GetMarketPricesByWoredaUseCase>(),
        getMarketPricesByProductUseCase: sl<GetMarketPricesByProductUseCase>(),
        getMarketPriceByIdUseCase: sl<GetMarketPriceByIdUseCase>(),
        updateMarketPriceUseCase: sl<UpdateMarketPriceUseCase>(),
        approveMarketPriceUseCase: sl<ApproveMarketPriceUseCase>(),
        rejectMarketPriceUseCase: sl<RejectMarketPriceUseCase>(),
        deleteMarketPriceUseCase: sl<DeleteMarketPriceUseCase>(),
        // Statistics Use Cases
        getProductPriceStatisticsUseCase:
            sl<GetProductPriceStatisticsUseCase>(),
        getRecentPriceAlertsUseCase: sl<GetRecentPriceAlertsUseCase>(),
      ),
    );
  }

  // Call the registration functions
  _registerMarketUseCases();
  _registerMarketBloc();
}

// ================= HELPER GETTERS =================
LocaleProvider getLocaleProvider() => sl<LocaleProvider>();
LanguageBloc getLanguageBloc() => sl<LanguageBloc>();

extension GetItLocalization on GetIt {
  LocaleProvider get localeProvider => get<LocaleProvider>();
  LanguageBloc get languageBloc => get<LanguageBloc>();
}
