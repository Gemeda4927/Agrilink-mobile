import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

class VerifyOtpPage extends StatefulWidget {
  final String identifier;
  final String purpose;
  final Map<String, dynamic>? userData;

  const VerifyOtpPage({
    super.key,
    required this.identifier,
    this.purpose = "SIGNUP",
    this.userData,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> with CodeAutoFill {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  String otpCode = "";
  int _seconds = 60;
  Timer? _timer;
  bool _canResend = false;

  // Modern color scheme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color softGrey = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF2C3E2F);

  @override
  void initState() {
    super.initState();
    listenForCode(); // Auto-detect OTP from SMS
    _startTimer();
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code ?? "";
      _codeController.text = otpCode;
    });

    if (otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _startTimer() {
    _seconds = 60;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _resendOtp() {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      otpCode = "";
      _codeController.clear();
    });

    // TODO: Implement resend OTP when endpoint is available
    // Commented out until resend endpoint is implemented
    /*
    if (widget.purpose == "RESET") {
      context.read<AuthBloc>().add(
        ForgotPasswordEvent(
          data: {"emailOrPhone": widget.identifier},
        ),
      );
    } else {
      context.read<AuthBloc>().add(
        ResendOtpEvent(
          data: {
            "identifier": widget.identifier,
            "purpose": widget.purpose,
          },
        ),
      );
    }
    */

    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Demo: OTP resent (backend endpoint coming soon)"),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _verifyOtp() {
    if (otpCode.length == 6) {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(
          data: {
            "identifier": widget.identifier,
            "code": otpCode,
            "purpose": widget.purpose,
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the 6-digit OTP"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightGreen, Colors.white, lightGreen],
          ),
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✓ OTP Verified Successfully"),
                    backgroundColor: primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Navigate based on purpose
                if (widget.purpose == "REGISTER") {
                  context.goNamed(RouteName.updateProfile);
                } else if (widget.purpose == "RESET") {
                  context.goNamed(
                    RouteName.resetPassword,
                    extra: {"identifier": widget.identifier},
                  );
                } else {
                  context.goNamed(RouteName.home);
                }
              }

              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }

              if (state is AuthMessage) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 18),
                            onPressed: () {
                              if (widget.purpose == "REGISTER") {
                                context.goNamed(RouteName.signup);
                              } else {
                                context.goNamed(RouteName.login);
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Animated Icon
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, double value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primaryGreen, Color(0xFF4CAF50)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryGreen.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        "Verify Your Identity",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Enter the 6-digit code sent to",
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.identifier,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // OTP Field Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // OTP Auto-fill Field with Manual Input Support
                                Column(
                                  children: [
                                    // PinFieldAutoFill for visual boxes
                                    PinFieldAutoFill(
                                      codeLength: 6,
                                      currentCode: otpCode,
                                      onCodeChanged: (code) {
                                        setState(() {
                                          otpCode = code ?? "";
                                          _codeController.text = otpCode;
                                        });
                                        if (otpCode.length == 6) {
                                          _verifyOtp();
                                        }
                                      },
                                      decoration: BoxLooseDecoration(
                                        strokeColorBuilder:
                                            const FixedColorBuilder(
                                              Colors.grey,
                                            ),
                                        bgColorBuilder: FixedColorBuilder(
                                          softGrey,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 8,
                                        ),
                                        gapSpace: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Hidden TextField for manual keyboard input
                                    // This ensures keyboard works properly
                                    Container(
                                      height: 0,
                                      width: 0,
                                      child: TextField(
                                        controller: _codeController,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        onChanged: (value) {
                                          setState(() {
                                            otpCode = value;
                                          });
                                          if (value.length == 6) {
                                            _verifyOtp();
                                          }
                                        },
                                        autofocus: true,
                                        showCursor: true,
                                        style: const TextStyle(fontSize: 0),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          counterText: "",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Manual OTP Input Field (Alternative)
                                Container(
                                  decoration: BoxDecoration(
                                    color: softGrey,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _codeController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 6,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      letterSpacing: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: "••••••",
                                      hintStyle: TextStyle(
                                        fontSize: 24,
                                        letterSpacing: 12,
                                        color: Colors.grey.shade400,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        otpCode = value;
                                      });
                                      if (value.length == 6) {
                                        _verifyOtp();
                                      }
                                    },
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Verify Button
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;

                                    return SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading || otpCode.length != 6
                                            ? null
                                            : _verifyOtp,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                "Verify OTP",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Resend Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _canResend
                                          ? "Didn't receive code? "
                                          : "Resend code in $_seconds s",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (_canResend)
                                      TextButton(
                                        onPressed: _resendOtp,
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryGreen,
                                        ),
                                        child: const Text(
                                          "Resend",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Help Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_outlined,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "We sent a code to your email",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
