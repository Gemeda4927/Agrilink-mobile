import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

class ResetPasswordPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  
  const ResetPasswordPage({super.key, this.extra});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _identifier;

  @override
  void initState() {
    super.initState();
    // Get identifier from navigation extras
    _identifier = widget.extra?['identifier'];
    
    // If no identifier, navigate back to forgot password
    if (_identifier == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(RouteName.forgotPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired. Please try again."),
            backgroundColor: Colors.orange,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthMessage) {
                // Password reset successful
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
                
                // Navigate to login page after successful reset
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    context.goNamed(RouteName.login);
                  }
                });
              }

              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const SizedBox(height: 20),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 30,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Create New Password",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your new password for $_identifier",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // New Password Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "New Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                            hintText: "Enter new password",
                          ),
                          // No validator
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                            hintText: "Re-enter new password",
                          ),
                          // No validator
                        ),
                        
                        const SizedBox(height: 32),

                        // Reset Password Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            bool isLoading = state is AuthLoading;
                            
                            return SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_identifier != null) {
                                          // Prepare data in required format
                                          final resetData = {
                                            "emailOrPhone": _identifier,
                                            "password": passwordController.text.trim(),
                                            "confirmPassword": confirmPasswordController.text.trim(),
                                          };
                                          
                                          context.read<AuthBloc>().add(
                                            ResetPasswordEvent(data: resetData),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Reset Password",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),

                        // Back to Login
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.goNamed(RouteName.login);
                            },
                            child: const Text(
                              "Back to Login",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                              ),
                            ),
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
      ),
    );
  }
}