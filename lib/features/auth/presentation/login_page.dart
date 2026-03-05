import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.agriculture, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login using email or phone",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email or Phone
                      TextFormField(
                        controller: _identifierController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: "Email or Phone",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter email or phone";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value != null && value.length >= 6
                                ? null
                                : "Password must be at least 6 characters",
                      ),
                      const SizedBox(height: 10),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.goNamed(RouteName.forgotPassword);
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BlocListener + BlocBuilder
                      BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Welcome ${state.authResponse.user.email}"),
                              ),
                            );
                            context.goNamed(RouteName.home);
                          }

                          if (state is AuthFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }

                          if (state is AuthMessage) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const CircularProgressIndicator();
                            }

                            return Column(
                              children: [
                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        final input =
                                            _identifierController.text.trim();

                                        Map<String, dynamic> data = {
                                          "password":
                                              _passwordController.text.trim(),
                                        };

                                        if (input.contains("@")) {
                                          data["email"] = input;
                                        } else {
                                          data["phone"] = input;
                                        }

                                        authBloc.add(SignInEvent(data: data));
                                      }
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Google Login
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.g_mobiledata,
                                      color: Colors.red,
                                      size: 28,
                                    ),
                                    label: const Text(
                                      "Sign in with Google",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      authBloc.add(GoogleSignInEvent());
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Create Account Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account?"),
                                    TextButton(
                                      onPressed: () {
                                        context.goNamed(RouteName.signup);
                                      },
                                      child: const Text(
                                        "Create Account",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
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