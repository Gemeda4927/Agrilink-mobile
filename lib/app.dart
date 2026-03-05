import 'package:agrilink/core/config/routes/app_router.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>())],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Agrilink',
        theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
        routerConfig: appRouter,
      ),
    );
  }
}
