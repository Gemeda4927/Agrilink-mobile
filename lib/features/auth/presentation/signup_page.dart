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

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String role = 'BUYER';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  // Password strength tracking
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChars = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF757575);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF43A047);
  static const Color warningOrange = Color(0xFFFFA000);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _addPasswordListeners();
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

  void _addPasswordListeners() {
    passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    setState(() {
      String password = passwordController.text;
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordController.removeListener(_updatePasswordStrength);
    _animationController.dispose();
    super.dispose();
  }

  // Show beautiful help dialog - FIXED VERSION
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // Set max width
            padding: const EdgeInsets.all(20), // Reduced padding
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.green.shade50],
              ),
            ),
            child: SingleChildScrollView(
              // Make it scrollable
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10), // Reduced padding
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryGreen, Colors.green.shade700],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 24, // Reduced size
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Password Requirements",
                          style: TextStyle(
                            fontSize: 20, // Reduced size
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Create a strong password to keep your account secure",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Requirements title
                  const Text(
                    "Your password must contain:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A2F),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Requirements list
                  _buildHelpRequirement(
                    "At least 8 characters",
                    "Minimum length for security",
                    Icons.text_fields,
                    _hasMinLength,
                  ),
                  const SizedBox(height: 6),
                  _buildHelpRequirement(
                    "One uppercase letter (A-Z)",
                    "Include capital letters",
                    Icons.arrow_upward,
                    _hasUppercase,
                  ),
                  const SizedBox(height: 6),
                  _buildHelpRequirement(
                    "One lowercase letter (a-z)",
                    "Include small letters",
                    Icons.arrow_downward,
                    _hasLowercase,
                  ),
                  const SizedBox(height: 6),
                  _buildHelpRequirement(
                    "One number (0-9)",
                    "Add digits for extra security",
                    Icons.numbers,
                    _hasDigits,
                  ),
                  const SizedBox(height: 6),
                  _buildHelpRequirement(
                    "One special character (!@#\$%^&*)",
                    "Use symbols to strengthen password",
                    Icons.emergency,
                    _hasSpecialChars,
                  ),
                  const SizedBox(height: 16),

                  // Example section - FIXED
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryGreen.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: warningOrange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              // Added Expanded
                              child: Text(
                                "Strong Password Example:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1E3A2F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Removed MainAxisAlignment.spaceBetween
                              Expanded(
                                // Added Expanded
                                child: Text(
                                  "StrongP@ssw0rd123",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Example copied to clipboard",
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                tooltip: "Copy example",
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Got it!",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpRequirement(
    String title,
    String subtitle,
    IconData icon,
    bool isMet,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMet ? successGreen.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMet ? successGreen : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isMet ? successGreen : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: isMet ? Colors.white : textGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isMet ? successGreen : Color(0xFF1E3A2F),
                    decoration: isMet ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(subtitle, style: TextStyle(fontSize: 11, color: textGrey)),
              ],
            ),
          ),
          if (isMet) Icon(Icons.check_circle, color: successGreen, size: 20),
        ],
      ),
    );
  }

  bool _isFormBasicValid() {
    if (!_agreeToTerms) return false;
    if (identifierController.text.trim().isEmpty) return false;
    if (passwordController.text.isEmpty) return false;
    if (confirmPasswordController.text.isEmpty) return false;
    if (confirmPasswordController.text != passwordController.text) return false;
    return true;
  }

  int _getPasswordStrength() {
    int strength = 0;
    if (_hasMinLength) strength++;
    if (_hasUppercase) strength++;
    if (_hasLowercase) strength++;
    if (_hasDigits) strength++;
    if (_hasSpecialChars) strength++;
    return strength;
  }

  String _getPasswordStrengthText() {
    int strength = _getPasswordStrength();
    if (strength <= 2) return "Weak";
    if (strength <= 3) return "Fair";
    if (strength <= 4) return "Good";
    return "Strong";
  }

  Color _getPasswordStrengthColor() {
    int strength = _getPasswordStrength();
    if (strength <= 2) return errorRed;
    if (strength <= 3) return warningOrange;
    if (strength <= 4) return primaryGreen;
    return successGreen;
  }

  double _getPasswordStrengthProgress() {
    return _getPasswordStrength() / 5;
  }

  String? _validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    }

    List<String> errors = [];

    if (value.length < 8) {
      errors.add("• At least 8 characters");
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      errors.add("• At least one uppercase letter");
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      errors.add("• At least one lowercase letter");
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      errors.add("• At least one number");
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add("• At least one special character (!@#\$%^&*)");
    }

    if (errors.isNotEmpty) {
      return "Password must contain:\n${errors.join('\n')}";
    }

    return null;
  }

  bool _isEmail(String input) {
    return input.contains('@') && input.contains('.');
  }

  bool _isPhoneNumber(String input) {
    String cleaned = input.replaceAll(RegExp(r'\s+'), '');

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

    if (_isEmail(value)) {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return "Enter a valid email address";
      }
      return null;
    }

    if (_isPhoneNumber(value)) {
      return null;
    }

    return "Enter a valid email or phone number\nExample: user@email.com or +251912345678";
  }

  String _formatPhoneNumberToInternational(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.startsWith('+251')) {
      return cleaned;
    }

    if (cleaned.startsWith('251')) {
      return '+$cleaned';
    }

    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+251${cleaned.substring(1)}';
    }

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Help Button at the top
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showHelpDialog,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGreen, Colors.green.shade700],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.help_outline, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "Help",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildPasswordStrengthIndicator() {
    if (passwordController.text.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: softGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Password Strength: ${_getPasswordStrengthText()}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getPasswordStrengthColor(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showHelpDialog,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.help, size: 16, color: textGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _getPasswordStrengthProgress(),
                backgroundColor: Colors.grey.shade300,
                color: _getPasswordStrengthColor(),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              Text(
                "Password Requirements:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textGrey,
                ),
              ),
              const SizedBox(height: 8),
              _buildRequirementTile("At least 8 characters", _hasMinLength),
              _buildRequirementTile(
                "At least one uppercase letter (A-Z)",
                _hasUppercase,
              ),
              _buildRequirementTile(
                "At least one lowercase letter (a-z)",
                _hasLowercase,
              ),
              _buildRequirementTile("At least one number (0-9)", _hasDigits),
              _buildRequirementTile(
                "At least one special character (!@#\$%^&*)",
                _hasSpecialChars,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementTile(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isMet ? successGreen : errorRed,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isMet ? successGreen : errorRed,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
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
                  hintText: "Create a strong password",
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
                validator: _validateStrongPassword,
              ),

              // Password strength indicator
              _buildPasswordStrengthIndicator(),
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
                  if (_validateStrongPassword(passwordController.text) !=
                      null) {
                    return "Please ensure your password meets all requirements above";
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

              // Bloc Listener and Builder
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

                    String identifier = identifierController.text.trim();
                    if (!_isEmail(identifier)) {
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
                    bool isBasicValid = _isFormBasicValid();

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
                            onPressed: state is AuthLoading || !isBasicValid
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
                        if (!_hasMinLength ||
                            !_hasUppercase ||
                            !_hasLowercase ||
                            !_hasDigits ||
                            !_hasSpecialChars)
                          if (passwordController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "Please make sure your password meets all requirements above",
                                style: TextStyle(fontSize: 12, color: errorRed),
                                textAlign: TextAlign.center,
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
