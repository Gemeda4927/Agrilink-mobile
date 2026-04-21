import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final identifierController = TextEditingController(); // Combined email/phone
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String role = 'BUYER';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==================== IDENTIFIER DETECTION & VALIDATION ====================

  bool _isEmail(String input) {
    return input.contains('@') && input.contains('.');
  }

  bool _isPhoneNumber(String input) {
    String cleaned = input.replaceAll(RegExp(r'\s+'), '');

    // Check for valid Ethiopian phone number formats
    if (RegExp(r'^\+251[1-9]\d{8}$').hasMatch(cleaned)) return true;
    if (RegExp(r'^251[1-9]\d{8}$').hasMatch(cleaned)) return true;
    if (RegExp(r'^0[1-9]\d{8}$').hasMatch(cleaned)) return true;
    if (RegExp(r'^[1-9]\d{8}$').hasMatch(cleaned)) return true;

    return false;
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter email or phone number";
    }

    // Check if it's a valid email
    if (_isEmail(value)) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return "Enter a valid email address";
      }
      return null; // Valid email
    }

    // Check if it's a valid phone number
    if (_isPhoneNumber(value)) {
      return null; // Valid phone
    }

    return "Enter a valid email or phone number\nExample: user@email.com or +251912345678";
  }

  String _formatPhoneNumberToInternational(String phone) {
    // Remove all spaces
    String cleaned = phone.replaceAll(RegExp(r'\s+'), '');

    // If already has +251, return as is
    if (cleaned.startsWith('+251')) {
      return cleaned;
    }

    // If starts with 251 (without +), add +
    if (cleaned.startsWith('251')) {
      return '+$cleaned';
    }

    // If starts with 0 (local format), convert to +251
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+251${cleaned.substring(1)}';
    }

    // If has 9 digits (no leading zero), add +251
    if (cleaned.length == 9) {
      return '+251$cleaned';
    }

    return cleaned;
  }

  Map<String, String> _prepareSignupData() {
    String identifier = identifierController.text.trim();
    Map<String, String> data = {
      "role": role,
      "password": passwordController.text.trim(),
      "confirmPassword": confirmPasswordController.text.trim(),
    };

    if (_isEmail(identifier)) {
      data["email"] = identifier;
      debugPrint('📧 Detected EMAIL: $identifier');
    } else {
      String formattedPhone = _formatPhoneNumberToInternational(identifier);
      data["phone"] = formattedPhone;
      debugPrint('📱 Detected PHONE (raw): $identifier');
      debugPrint('📱 Detected PHONE (formatted): $formattedPhone');
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white, Colors.green.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildSignUpForm(authBloc),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, primaryGreen],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade200.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Create Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A2F),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Join our community today",
          style: TextStyle(fontSize: 16, color: Color(0xFF5E6D5C)),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(AuthBloc authBloc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Combined Email or Phone Field
              TextFormField(
                controller: identifierController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.alternate_email,
                    color: primaryGreen,
                  ),
                  labelText: "Email or Phone Number",
                  hintText: "user@email.com or +251912345678",
                  helperText: "Enter your email address or phone number",
                  helperStyle: const TextStyle(fontSize: 11, color: textGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: softGrey,
                ),
                validator: _validateIdentifier,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: primaryGreen,
                  ),
                  labelText: "Password",
                  hintText: "Create a password (min 6 characters)",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: primaryGreen,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: softGrey,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: primaryGreen,
                  ),
                  labelText: "Confirm Password",
                  hintText: "Re-enter your password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: primaryGreen,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: softGrey,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role Selection
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: softGrey,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: "Select Role",
                    prefixIcon: Icon(Icons.person_outline, color: primaryGreen),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down_circle,
                    color: primaryGreen,
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: "BUYER",
                      child: Text("BUYER - I want to buy products"),
                    ),
                    DropdownMenuItem(
                      value: "FARMER",
                      child: Text("FARMER - I want to sell products"),
                    ),
                    DropdownMenuItem(
                      value: "AGENT",
                      child: Text("AGENT - I want to help farmers"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        role = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreeToTerms = !_agreeToTerms;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: textGrey, fontSize: 14),
                          children: [
                            const TextSpan(text: "I agree to the "),
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bloc Listener
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
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

                    // Send the identifier (email or phone) that user entered
                    String identifier = identifierController.text.trim();
                    if (!_isEmail(identifier)) {
                      // If it's a phone, send formatted version
                      identifier = _formatPhoneNumberToInternational(
                        identifier,
                      );
                    }

                    context.goNamed(
                      RouteName.verifyOtp,
                      extra: {"identifier": identifier, "purpose": "SIGNUP"},
                    );
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
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: state is AuthLoading || !_agreeToTerms
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      Map<String, String> signupData =
                                          _prepareSignupData();

                                      debugPrint('📝 Signup Data:');
                                      debugPrint(
                                        '   Role: ${signupData["role"]}',
                                      );
                                      debugPrint(
                                        '   Email: ${signupData["email"] ?? "N/A"}',
                                      );
                                      debugPrint(
                                        '   Phone: ${signupData["phone"] ?? "N/A"}',
                                      );

                                      authBloc.add(
                                        SignUpEvent(data: signupData),
                                      );
                                    }
                                  },
                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(color: Color(0xFF5E6D5C)),
        ),
        TextButton(
          onPressed: () {
            context.goNamed(RouteName.login);
          },
          style: TextButton.styleFrom(foregroundColor: primaryGreen),
          child: const Text(
            "Login",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
