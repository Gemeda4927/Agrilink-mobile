import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';

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

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with CodeAutoFill {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  bool _isOtpSent = false;
  String? _identifier;

  /// OTP
  String otpCode = "";

  /// TIMER
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    listenForCode(); // 📲 AUTO OTP LISTENER
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    emailController.dispose();
    super.dispose();
  }

  /// 📲 AUTO OTP DETECT
  @override
  void codeUpdated() {
    setState(() {
      otpCode = code ?? "";
    });

    if (otpCode.length == 6) {
      _verifyOtp();
    }
  }

  /// ⏱️ TIMER
  void _startTimer() {
    _seconds = 30;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  /// 🔐 VERIFY OTP
  void _verifyOtp() {
    if (otpCode.length == 6) {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(
          data: {
            "identifier": _identifier,
            "code": otpCode,
            "purpose": "RESET",
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter full OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthMessage) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));

              setState(() {
                _isOtpSent = true;
                _identifier = emailController.text.trim();
              });

              _startTimer();
            }

            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("OTP Verified Successfully")),
              );

              context.goNamed(
                RouteName.resetPassword,
                extra: {"identifier": _identifier},
              );
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
                /// 🔙 BACK BUTTON
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => context.pop(),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔐 ICON
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

                /// TITLE
                Text(
                  _isOtpSent ? "Verify OTP" : "Forgot Password",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// SUBTITLE
                Text(
                  _isOtpSent
                      ? "Enter the 6-digit code sent to\n$_identifier"
                      : "Enter your email to receive a reset code",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 40),

                /// CARD
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
                        /// EMAIL
                        if (!_isOtpSent)
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Enter email" : null,
                          ),

                        /// OTP FIELD
                        if (_isOtpSent) ...[
                          PinFieldAutoFill(
                            codeLength: 6,
                            currentCode: otpCode,
                            onCodeChanged: (code) {
                              setState(() => otpCode = code ?? "");
                            },
                            decoration: BoxLooseDecoration(
                              strokeColorBuilder: const FixedColorBuilder(
                                Colors.grey,
                              ),
                              bgColorBuilder: FixedColorBuilder(
                                Colors.grey.shade50,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// TIMER / RESEND
                          _seconds == 0
                              ? TextButton(
                                  onPressed: () {
                                    authBloc.add(
                                      ForgotPasswordEvent(
                                        data: {"emailOrPhone": _identifier},
                                      ),
                                    );
                                    _startTimer();
                                  },
                                  child: const Text(
                                    "Resend OTP",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Resend in $_seconds s",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                        ],

                        const SizedBox(height: 25),

                        /// BUTTON
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;

                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          if (!_isOtpSent) {
                                            authBloc.add(
                                              ForgotPasswordEvent(
                                                data: {
                                                  "emailOrPhone":
                                                      emailController.text
                                                          .trim(),
                                                },
                                              ),
                                            );
                                          } else {
                                            _verifyOtp();
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        _isOtpSent ? "Verify OTP" : "Send Code",
                                        style: const TextStyle(fontSize: 16),
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

                /// BACK TO LOGIN
                TextButton(
                  onPressed: () => context.goNamed(RouteName.login),
                  child: const Text("Back to Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
