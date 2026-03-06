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
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isOtpSent = false;
  String? _identifier;

  @override
  void dispose() {
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChange(int index, String value) {
    if (value.length == 1 && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

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
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );

              // OTP sent successfully - show OTP input field
              setState(() {
                _isOtpSent = true;
                _identifier = emailController.text.trim();
              });
            }

            if (state is AuthSuccess) {
              // OTP verified successfully - navigate directly to reset password
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("OTP verified successfully"),
                  backgroundColor: Colors.green,
                ),
              );

              // Navigate to reset password with identifier
              context.goNamed(
                RouteName.resetPassword,
                extra: {
                  "identifier": _identifier,
                },
              );
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isOtpSent) ...[
                    // Email Input Section
                    const Text(
                      "Enter your registered email address",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        hintText: "example@email.com",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!value.contains("@") || !value.contains(".")) {
                          return "Enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                  ] else ...[
                    // OTP Input Section
                    const Text(
                      "Enter OTP",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We've sent a 6-digit verification code to $_identifier",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    
                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 45,
                          height: 55,
                          child: TextFormField(
                            controller: otpControllers[index],
                            focusNode: otpFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _onOtpChange(index, value);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Resend OTP option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive code? "),
                        TextButton(
                          onPressed: () {
                            if (_identifier != null) {
                              authBloc.add(
                                ForgotPasswordEvent(
                                  data: {
                                    "emailOrPhone": _identifier,
                                  },
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Resend OTP",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 30),

                  // Action Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (!_isOtpSent) {
                                // Send OTP
                                authBloc.add(
                                  ForgotPasswordEvent(
                                    data: {
                                      "emailOrPhone": emailController.text.trim(),
                                    },
                                  ),
                                );
                              } else {
                                // Verify OTP - using the required data structure
                                final otpCode = _getOtpCode();
                                if (otpCode.length == 6) {
                                  authBloc.add(
                                    VerifyOtpEvent(
                                      data: {
                                        "identifier": _identifier,
                                        "code": otpCode, // Changed from 'otp' to 'code'
                                        "purpose": "RESET",
                                      },
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please enter complete OTP"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _isOtpSent ? "Verify OTP" : "Send Reset Link",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  
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

                  if (_isOtpSent) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            for (var controller in otpControllers) {
                              controller.clear();
                            }
                          });
                        },
                        child: const Text(
                          "Change Email",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}