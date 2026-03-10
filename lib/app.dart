import 'package:agrilink/core/config/routes/app_router.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';

import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';

import 'package:agrilink/injector.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AUTH
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),

        // CATEGORY
        BlocProvider<CategoryBloc>(
          create: (_) => sl<CategoryBloc>()..add(LoadCategories()),
        ),

        // REGISTRATION
        BlocProvider<RegistrationBloc>(
          create: (_) => sl<RegistrationBloc>()..add(LoadRegions()),
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
