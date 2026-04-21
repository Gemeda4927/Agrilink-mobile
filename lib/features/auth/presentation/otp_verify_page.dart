// features/auth/presentation/otp_verify_page.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:flutter/services.dart';

class VerifyOtpPage extends StatefulWidget {
  final String identifier;
  final String purpose;
  final Map<String, dynamic>? userData; // For registration data

  const VerifyOtpPage({
    super.key,
    required this.identifier,
    this.purpose = "RESET",
    this.userData,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  int _seconds = 60;
  bool _canResend = false;
  Timer? _timer;
  bool _isVerifying = false;
  int _failedAttempts = 0;

  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _timer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 60;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        if (mounted) setState(() => _canResend = true);
        timer.cancel();
      } else {
        if (mounted) setState(() => _seconds--);
      }
    });
  }

  String _getOtp() {
    return _controllers.map((e) => e.text).join();
  }

  void _verifyOtp() {
    final otp = _getOtp();

    if (otp.length != 6) {
      _shake();
      _showSnackBar(
        "Please enter complete 6-digit code",
        isError: true,
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Map the purpose to what the backend expects
    String backendPurpose;
    switch (widget.purpose.toUpperCase()) {
      case "REGISTER":
        backendPurpose = "SIGNUP"; // Backend might expect SIGNUP instead of REGISTER
        break;
      case "RESET":
        backendPurpose = "RESET";
        break;
      case "LOGIN":
        backendPurpose = "LOGIN";
        break;
      default:
        backendPurpose = widget.purpose;
    }

    print("🔐 Verifying OTP: $otp for ${widget.identifier} with purpose: $backendPurpose");

    context.read<AuthBloc>().add(
      VerifyOtpEvent(
        data: {
          "identifier": widget.identifier,
          "code": otp,
          "purpose": backendPurpose,
        },
      ),
    );
  }

  void _skipVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Skip Verification?"),
        content: Text(
          widget.purpose == "RESET"
              ? "Skipping OTP verification means you won't be able to reset your password. Are you sure?"
              : "Are you sure you want to skip verification? Your account may have limited access.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNextScreen();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Skip Anyway"),
          ),
        ],
      ),
    );
  }

  void _navigateToNextScreen() {
    if (widget.purpose == "RESET") {
      context.goNamed(RouteName.home);
      _showSnackBar(
        "Verification skipped. You can reset password later from profile.",
        isError: false,
      );
    } else if (widget.purpose == "REGISTER") {
      context.goNamed(RouteName.home);
      _showSnackBar(
        "Verification skipped. Please verify your email later.",
        isError: false,
      );
    } else {
      context.pop();
    }
  }

  void _shake() {
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  void _resendOtp() {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _isVerifying = false;
      _failedAttempts = 0; // Reset failed attempts on resend
    });
    _startTimer();

    // Clear all OTP fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    // Use the appropriate event based on purpose
    if (widget.purpose == "REGISTER") {
      // Resend OTP for registration
      context.read<AuthBloc>().add(
        SignUpEvent(
          data: {
            "email": widget.identifier,
            // Add other registration data if needed
          },
        ),
      );
    } else {
      // Resend OTP for password reset
      context.read<AuthBloc>().add(
        ForgotPasswordEvent(
          data: {"emailOrPhone": widget.identifier},
        ),
      );
    }

    _showSnackBar(
      "OTP resent successfully!",
      isError: false,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePaste() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      final pastedText = data.text?.trim() ?? '';
      if (pastedText.length == 6 && RegExp(r'^\d+$').hasMatch(pastedText)) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = pastedText[i];
        }
        _verifyOtp();
      } else {
        _showSnackBar(
          "Invalid OTP format. Please enter 6 digits.",
          isError: true,
        );
      }
    }
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 52,
      height: 68,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: _controllers[index].text.isNotEmpty
              ? Colors.green.shade50
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.green.shade400, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          
          if (_getOtp().length == 6) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  String _formatIdentifier() {
    final text = widget.identifier;
    if (text.contains('@')) {
      final parts = text.split('@');
      if (parts[0].length > 10) {
        return '${parts[0].substring(0, 8)}...@${parts[1]}';
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFE),
        appBar: AppBar(
          title: const Text(
            "Verify OTP",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            onPressed: () => context.goNamed(RouteName.login),
          ),
          actions: [
            TextButton(
              onPressed: _skipVerification,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text(
                "Skip",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            setState(() => _isVerifying = false);

            if (state is AuthSuccess) {
              _showSnackBar(
                "OTP Verified Successfully!",
                isError: false,
              );

              if (widget.purpose == "RESET") {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    context.pushNamed(
                      RouteName.resetPassword,
                      extra: {"identifier": widget.identifier},
                    );
                  }
                });
              } else if (widget.purpose == "REGISTER") {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    if (widget.userData != null) {
                      context.goNamed(
                        RouteName.updateProfile,
                        extra: widget.userData,
                      );
                    } else {
                      context.goNamed(RouteName.home);
                    }
                  }
                });
              } else {
                context.goNamed(RouteName.home);
              }
            }

            if (state is AuthFailure) {
              setState(() {
                _failedAttempts++;
              });
              
              _shake();
              
              // Show more helpful error messages
              String errorMessage = state.error;
              if (errorMessage.contains("400") || errorMessage.contains("bad syntax")) {
                errorMessage = "Invalid OTP code. Please check and try again.";
              } else if (errorMessage.contains("expired")) {
                errorMessage = "OTP has expired. Please request a new code.";
              }
              
              _showSnackBar(errorMessage, isError: true);
              
              // Clear all fields on failure after 3 attempts
              if (_failedAttempts >= 3) {
                for (var controller in _controllers) {
                  controller.clear();
                }
                _showSnackBar(
                  "Too many failed attempts. Please request a new OTP.",
                  isError: true,
                );
              }
              
              _focusNodes[0].requestFocus();
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Animated Icon
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade700,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Title
                  const Text(
                    "Verification Required",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Subtitle
                  Text(
                    "Enter the 6-digit code sent to",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      _formatIdentifier(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// OTP Boxes with Shake Animation
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final offset = sin(_shakeController.value * pi * 8) * 6;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) => _buildOtpBox(index)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Paste Button
                  TextButton.icon(
                    onPressed: _handlePaste,
                    icon: Icon(Icons.content_paste, size: 18, color: Colors.grey.shade600),
                    label: Text(
                      "Paste OTP",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Verify Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading || _isVerifying;

                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Verify & Continue",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  if (widget.purpose == "RESET")
                    TextButton(
                      onPressed: _skipVerification,
                      child: Text(
                        "Skip for now",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  /// Resend Section
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _canResend ? "Didn't receive the code?" : "Code expires in",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        if (!_canResend) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${_seconds}s",
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_canResend) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _resendOtp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                "Resend",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Help Text
                  Center(
                    child: GestureDetector(
                      onTap: _showHelpDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Need help?",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent,
                  size: 32,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Need Assistance?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "If you didn't receive the verification code, please:\n\n"
                "• Check your spam/junk folder\n"
                "• Verify you entered the correct email address\n"
                "• Wait a moment and try resending the code\n"
                "• Make sure you're using the latest code\n"
                "• Contact support if the issue persists",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}