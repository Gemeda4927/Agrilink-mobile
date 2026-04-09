import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String role = 'FARMER';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Modern color scheme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color softGrey = Color(0xFFF8F9FA);
  static const Color textGrey = Color(0xFF6C757D);
  static const Color darkText = Color(0xFF2C3E2F);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      _agreeToTerms = false;
    });
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
            colors: [lightGreen, Colors.white, lightGreen],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildRegisterForm(authBloc),
                      const SizedBox(height: 24),
                      _buildFooter(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
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
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.agriculture_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Add New Farmer",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Register farmer to the system",
            style: TextStyle(
              fontSize: 14,
              color: primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthBloc authBloc) {
    return Container(
      width: double.infinity,
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
              _buildTextField(
                controller: nameController,
                label: "Full Name",
                hint: "Enter farmer's full name",
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter full name";
                  }
                  if (value.trim().length < 3) {
                    return "Name must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                label: "Email Address",
                hint: "farmer@example.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email";
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: phoneController,
                label: "Phone Number",
                hint: "0912345678",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter phone number";
                  }
                  final phoneRegex = RegExp(r'^[0-9]{10}$');
                  if (!phoneRegex.hasMatch(value.trim())) {
                    return "Enter a valid 10-digit phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: passwordController,
                label: "Password",
                hint: "Create a secure password",
                isVisible: _isPasswordVisible,
                onToggle: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
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
              _buildPasswordField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                hint: "Re-enter your password",
                isVisible: _isConfirmPasswordVisible,
                onToggle: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
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
              const SizedBox(height: 20),
              _buildTermsCheckbox(),
              const SizedBox(height: 24),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthMessage) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        context.pushNamed(
                          RouteName.verifyOtp,
                          extra: {
                            "identifier": emailController.text.trim(),
                            "purpose": "REGISTER",
                            "userData": {
                              "name": nameController.text.trim(),
                              "email": emailController.text.trim(),
                              "phone": phoneController.text.trim(),
                              "password": passwordController.text.trim(),
                            },
                          },
                        );
                      }
                    });
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
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: state is AuthLoading || !_agreeToTerms
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  authBloc.add(
                                    SignUpEvent(
                                      data: {
                                        "name": nameController.text.trim(),
                                        "role": role,
                                        "email": emailController.text.trim(),
                                        "phone": phoneController.text.trim(),
                                        "password": passwordController.text
                                            .trim(),
                                        "confirmPassword":
                                            confirmPasswordController.text
                                                .trim(),
                                      },
                                    ),
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
                                "Register Farmer",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
    bool textCapitalization = true,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization
          ? TextCapitalization.words
          : TextCapitalization.none,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryGreen, size: 22),
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: textGrey,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: textGrey.withOpacity(0.7), fontSize: 14),
        filled: true,
        fillColor: softGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: primaryGreen,
          size: 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: primaryGreen,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: textGrey,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: textGrey.withOpacity(0.7), fontSize: 14),
        filled: true,
        fillColor: softGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Transform.scale(
          scale: 0.9,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            activeColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
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
                style: const TextStyle(color: textGrey, fontSize: 13),
                children: [
                  const TextSpan(
                    text: "I confirm that the information is accurate and ",
                  ),
                  TextSpan(
                    text: "agree to terms",
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
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Need to clear form?",
          style: TextStyle(color: textGrey, fontSize: 14),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _clearForm,
          style: TextButton.styleFrom(
            foregroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(
            "Reset Form",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
