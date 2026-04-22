import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:agrilink/core/localization/language_bloc.dart';
import 'package:agrilink/core/services/notification_service.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_bloc.dart';
import 'package:agrilink/features/insight/presentation/bloc/market_event.dart';
import 'package:agrilink/features/notification/presentation/notification_bloc.dart';
import 'package:agrilink/features/order/presentation/bloc/order_bloc.dart';
import 'package:agrilink/features/order/presentation/bloc/order_event.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_event.dart';
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

// Global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final NotificationService _notificationService;

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
    await _notificationService.initialize();

    NotificationService.navigateTo =
        (String route, {Map<String, dynamic>? extra}) {
          final context = rootNavigatorKey.currentState?.context;
          if (context != null) {
            final currentRoute = GoRouterState.of(context).uri.toString();
            if (currentRoute != route) {
              context.pushNamed(route, extra: extra);
            }
          }
        };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Use injected LanguageBloc from GetIt (singleton instance)
        BlocProvider<LanguageBloc>(create: (_) => sl<LanguageBloc>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),

        // Notification BLoC
        BlocProvider<NotificationBloc>(
          create: (_) {
            final bloc = sl<NotificationBloc>();
            bloc.add(InitializeNotifications());
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

        // Buyer Orders
        BlocProvider<OrderBloc>(
          create: (_) {
            final bloc = sl<OrderBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(GetMyOrdersEvent());
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

        // ================= MARKET INSIGHT BLoC =================
        BlocProvider<MarketBloc>(
          create: (_) {
            final bloc = sl<MarketBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Load initial data when market screen is accessed
              // You can optionally load products here if needed
              // bloc.add(GetAllProductsEvent());
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
              // Fallback delegates for unsupported locales
              const OromoMaterialLocalizationsDelegate(),
              const OromoCupertinoLocalizationsDelegate(),
              const AmharicMaterialLocalizationsDelegate(),
              const AmharicCupertinoLocalizationsDelegate(),
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Handle locale resolution with proper fallback
              if (locale == null) {
                return const Locale('en', 'US');
              }

              // Check if the language code is supported
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
              appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
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
            // Auth state listener for token registration
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    _registerDeviceTokenAndSubscribe(state);
                  } else if (state is AuthInitial) {
                    _unregisterDeviceToken();
                  }
                },
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _registerDeviceTokenAndSubscribe(AuthSuccess state) async {
    try {
      final token = await _notificationService.getSavedToken();

      if (token != null && token.isNotEmpty) {
        await _notificationService.registerDeviceToken(token);
      }

      // Safe role extraction
      final user = state.authResponse.user;
      final role = user.role;

      if (role != null && role.toString().isNotEmpty) {
        final normalizedRole = role.toString().toLowerCase().trim();

        await _notificationService.subscribeToTopic('all_users');
        await _notificationService.subscribeToTopic('role_$normalizedRole');
      } else {
        // fallback subscription
        await _notificationService.subscribeToTopic('all_users');
      }
    } catch (e, stackTrace) {
      // You should log this instead of silent fail in production
      sl<Logger>().e(
        'Failed to register device token and subscribe to topics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _unregisterDeviceToken() async {
    try {
      await _notificationService.unregisterDeviceToken();
    } catch (e) {
      // Silent fail
    }
  }

  /// Get font family based on language code
  String _getFontFamily(String languageCode) {
    switch (languageCode) {
      case 'am':
        return 'NotoSansEthiopic';
      case 'om':
        return 'Roboto'; // Oromo uses standard font
      default:
        return 'Roboto';
    }
  }
}

// ================= FALLBACK LOCALIZATION DELEGATES =================

/// Material fallback: Maps Oromo ('om') requests to English Material translations
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

/// Cupertino fallback: Maps Oromo ('om') requests to English Cupertino translations
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

/// Material fallback: Maps Amharic ('am') requests to English Material translations
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
