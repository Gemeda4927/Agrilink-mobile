import 'package:agrilink/features/cart/presentation/bloc/cart_event.dart';
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
import 'package:agrilink/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:agrilink/injector.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ================= AUTH =================
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),

        // ================= CATEGORY =================
        BlocProvider<CategoryBloc>(
          create: (_) => sl<CategoryBloc>()..add(LoadCategories()),
        ),

        // ================= PRODUCT =================
        BlocProvider<ProductBloc>(
          create: (_) => sl<ProductBloc>()..add(LoadProducts()),
        ),

        // ================= REGISTRATION =================
        BlocProvider<RegistrationBloc>(
          create: (_) => sl<RegistrationBloc>()..add(LoadRegions()),
        ),

        // ================= ROLE REQUEST =================
        BlocProvider<RoleRequestBloc>(create: (_) => sl<RoleRequestBloc>()),

        // ================= PROFILE =================
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),

        // ================= CHAT =================
        BlocProvider<ChatBloc>(lazy: false, create: (_) => sl<ChatBloc>()),

        // ================= CART =================
        BlocProvider<CartBloc>(
          create: (_) {
            final cartBloc = sl<CartBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cartBloc.add(LoadCart());
            });
            return cartBloc;
          },
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
