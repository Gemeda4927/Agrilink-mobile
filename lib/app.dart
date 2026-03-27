// my_app.dart - Make sure ChatBloc2 is REMOVED from MultiBlocProvider
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:agrilink/features/chat/presentation/bloc/chat_event.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
import 'package:agrilink/injector.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ================= AUTH =================
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>(), lazy: false),

        // ================= CATEGORY =================
        BlocProvider<CategoryBloc>(
          create: (_) {
            final bloc = sl<CategoryBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadCategories());
            });
            return bloc;
          },
          lazy: false,
        ),

        // ================= PRODUCT =================
        BlocProvider<ProductBloc>(
          create: (_) {
            final bloc = sl<ProductBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadProducts());
            });
            return bloc;
          },
          lazy: false,
        ),

        // ================= REGISTRATION =================
        BlocProvider<RegistrationBloc>(
          create: (_) {
            final bloc = sl<RegistrationBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(LoadRegions());
            });
            return bloc;
          },
          lazy: false,
        ),

        // ================= ROLE REQUEST =================
        BlocProvider<RoleRequestBloc>(
          create: (_) => sl<RoleRequestBloc>(),
          lazy: false,
        ),

        // ================= PROFILE =================
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>(),
          lazy: false,
        ),

        // ================= CHAT (OLD SYSTEM) =================
        BlocProvider<ChatBloc>(
          create: (_) {
            final chatBloc = sl<ChatBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              chatBloc.add(LoadConversationsEvent());
            });
            return chatBloc;
          },
          lazy: false,
        ),

        // ================= CART =================
        BlocProvider<CartBloc>(
          create: (_) {
            final cartBloc = sl<CartBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cartBloc.add(LoadCart());
            });
            return cartBloc;
          },
          lazy: false,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Agrilink',
        theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
        routerConfig: appRouter,
      ),
    );
  }
}
