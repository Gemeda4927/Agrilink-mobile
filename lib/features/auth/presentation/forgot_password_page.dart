// features/auth/presentation/forgot_password_page.dart
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
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _sendResetCode() {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();

      context.read<AuthBloc>().add(
        ForgotPasswordEvent(data: {"emailOrPhone": email}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthMessage) {
              // Navigate to OTP screen when code is sent
              context.pushNamed(
                RouteName.verifyOtp,
                extra: {
                  'identifier': emailController.text.trim(),
                  'purpose': 'RESET',
                },
              );

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                /// Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => context.pop(),
                  ),
                ),

                const SizedBox(height: 20),

                /// Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 20),

                /// Title
                const Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                /// Subtitle
                Text(
                  "Enter your email address and we'll send\nyou a verification code",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 40),

                /// Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// Email Field
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 25),

                        /// Send Code Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;

                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _sendResetCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Send Reset Code",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Back to Login
                TextButton(
                  onPressed: () => context.goNamed(RouteName.login),
                  child: Text(
                    "Back to Login",
                    style: TextStyle(color: Colors.grey.shade600),
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
