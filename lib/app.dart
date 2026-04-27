import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:agrilink/core/localization/language_bloc.dart';
import 'package:agrilink/core/services/notification_service.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_bloc.dart';
import 'package:agrilink/features/my_product/presentation/bloc/farmer_order_events.dart';
import 'package:agrilink/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:agrilink/features/order/presentation/bloc/order_bloc.dart';
import 'package:agrilink/features/order/presentation/bloc/order_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:agrilink/core/config/routes/app_router.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';
import 'package:agrilink/features/product/presentation/bloc/product_bloc.dart';
import 'package:agrilink/features/product/presentation/bloc/product_event.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_bloc.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:agrilink/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/injector.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final NotificationService _notificationService;
  final Logger _logger = sl<Logger>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService = sl<NotificationService>();
    _initializeNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notificationService.clearBadge();
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
      _logger.i("✅ Notification service initialized successfully");

      NotificationService.navigateTo =
          (String route, {Map<String, dynamic>? extra}) {
            final context = navigatorKey.currentState?.context;
            if (context != null) {
              try {
                final currentRoute = GoRouterState.of(context).uri.toString();
                if (currentRoute != route) {
                  _logger.i("📱 Navigating to: $route");
                  context.pushNamed(route, extra: extra);
                }
              } catch (e) {
                _logger.e("Navigation error: $e");
                context.pushNamed(route, extra: extra);
              }
            }
          };
    } catch (e, stackTrace) {
      _logger.e(
        "Failed to initialize notifications",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageBloc>(create: (_) => sl<LanguageBloc>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),

        BlocProvider<NotificationBloc>(
          create: (_) {
            final bloc = sl<NotificationBloc>();

            // });
            return bloc;
          },
        ),

        BlocProvider<CategoryBloc>(
          create: (_) {
            final bloc = sl<CategoryBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadCategories());
            });
            return bloc;
          },
        ),

        BlocProvider<ProductBloc>(
          create: (_) {
            final bloc = sl<ProductBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadProducts());
            });
            return bloc;
          },
        ),

        BlocProvider<RegistrationBloc>(
          create: (_) {
            final bloc = sl<RegistrationBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadRegions());
            });
            return bloc;
          },
        ),

        BlocProvider<OrderBloc>(
          create: (_) {
            final bloc = sl<OrderBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(GetMyOrdersEvent());
            });
            return bloc;
          },
        ),

        BlocProvider<FarmerOrderBloc>(
          create: (_) {
            final bloc = sl<FarmerOrderBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadFarmerOrdersEvent());
            });
            return bloc;
          },
        ),

        BlocProvider<RoleRequestBloc>(create: (_) => sl<RoleRequestBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
        BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),

        BlocProvider<CartBloc>(
          create: (_) {
            final bloc = sl<CartBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadCart());
            });
            return bloc;
          },
        ),

        BlocProvider<MarketBloc>(
          create: (_) {
            final bloc = sl<MarketBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Load initial market data when needed
            });
            return bloc;
          },
        ),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, langState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Agrilink',
            locale: langState.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('am', 'ET'),
              Locale('om', 'ET'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              const OromoMaterialLocalizationsDelegate(),
              const OromoCupertinoLocalizationsDelegate(),
              const AmharicMaterialLocalizationsDelegate(),
              const AmharicCupertinoLocalizationsDelegate(),
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) {
                return const Locale('en', 'US');
              }
              final supportedLocale = supportedLocales.firstWhere(
                (supported) => supported.languageCode == locale.languageCode,
                orElse: () => const Locale('en', 'US'),
              );
              return supportedLocale;
            },
            theme: ThemeData(
              primarySwatch: Colors.green,
              useMaterial3: true,
              fontFamily: _getFontFamily(langState.locale.languageCode),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            routerConfig: appRouter,
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  _logger.i("🔔 AuthState changed: ${state.runtimeType}");

                  // ✅ REMOVED: No notification registration on login
                  // Just log the state change, nothing else
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  // ✅ REMOVED: _registerDeviceTokenAndSubscribe method completely
  // ✅ REMOVED: _unregisterDeviceToken method completely

  String _getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'am':
        return 'NotoSansEthiopic';
      case 'om':
        return 'Roboto';
      default:
        return 'Roboto';
    }
  }
}

// ================= FALLBACK LOCALIZATION DELEGATES =================

class OromoMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const OromoMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return await GlobalMaterialLocalizations.delegate.load(
      const Locale('en', 'US'),
    );
  }

  @override
  bool shouldReload(OromoMaterialLocalizationsDelegate old) => false;
}

class OromoCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const OromoCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return await GlobalCupertinoLocalizations.delegate.load(
      const Locale('en', 'US'),
    );
  }

  @override
  bool shouldReload(OromoCupertinoLocalizationsDelegate old) => false;
}

class AmharicMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const AmharicMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'am';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return await GlobalMaterialLocalizations.delegate.load(
      const Locale('en', 'US'),
    );
  }

  @override
  bool shouldReload(AmharicMaterialLocalizationsDelegate old) => false;
}

class AmharicCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const AmharicCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'am';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return await GlobalCupertinoLocalizations.delegate.load(
      const Locale('en', 'US'),
    );
  }

  @override
  bool shouldReload(AmharicCupertinoLocalizationsDelegate old) => false;
}
