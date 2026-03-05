import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.goNamed(RouteName.login);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final user = state.authResponse.user;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.email}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('User ID: ${user.id}'),
                  Text('Phone: ${user.phone}'),
                  Text('Role: ${user.role}'),
                  Text('Status: ${user.status}'),
                  Text('Joined: ${user.createdAt.toLocal()}'),
                ],
              ),
            );
            // ignore: dead_code
          } else {
            return const Center(
              child: Text('No user data found. Please login.'),
            );
          }
        },
      ),
    );
  }
}
