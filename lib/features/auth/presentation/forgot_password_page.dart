import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthMessage) {
              // Show message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );

              // Navigate to OTP verification for RESET
              context.goNamed(
                RouteName.verifyOtp,
                extra: {
                  "identifier": emailController.text.trim(),
                  "purpose": "RESET",
                },
              );
            }

            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Enter your email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!value.contains("@")) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator();
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 50,



                  ElevatedButton(
  onPressed: () {
    authBloc.add(
      ForgotPasswordEvent(
        data: {
          "emailOrPhone": emailController.text.trim(), 
        },
      ),
    );
  },
  child: const Text("Send Reset Link"),
)





                    );
                  },
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.goNamed(RouteName.login);
                  },
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}