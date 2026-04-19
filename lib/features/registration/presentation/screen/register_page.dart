import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_state.dart';

class CreateFarmerScreen extends StatefulWidget {
  const CreateFarmerScreen({super.key});

  @override
  State<CreateFarmerScreen> createState() => _CreateFarmerScreenState();
}

class _CreateFarmerScreenState extends State<CreateFarmerScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _showReview = false;

  // Color scheme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF757575);
  static const Color cardGrey = Color(0xFFFAFAFA);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    String cleaned = phone.trim();
    cleaned = cleaned.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleaned.startsWith('0')) {
      return '+251${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+')) {
      return '+251$cleaned';
    } else if (cleaned.startsWith('+') && !cleaned.startsWith('+251')) {
      return '+251${cleaned.substring(1)}';
    }
    
    return cleaned;
  }

  bool _validateForm() {
    if (_emailController.text.isEmpty) {
      _showErrorSnackBar('Please enter email');
      return false;
    }
    if (!_emailController.text.contains('@') || 
        !_emailController.text.contains('.')) {
      _showErrorSnackBar('Please enter a valid email address');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter password');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showErrorSnackBar('Password must be at least 8 characters');
      return false;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Please confirm password');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter phone number');
      return false;
    }
    
    String formattedPhone = _formatPhoneNumber(_phoneController.text);
    if (formattedPhone.length < 12 || formattedPhone.length > 14) {
      _showErrorSnackBar('Please enter a valid phone number (e.g., 0912345678 or +251912345678)');
      return false;
    }
    
    return true;
  }

  void _showReviewDialog() {
    if (!_validateForm()) return;
    
    setState(() {
      _showReview = true;
    });
  }

  void _confirmCreate() {
    String formattedPhone = _formatPhoneNumber(_phoneController.text);
    
    context.read<RegistrationBloc>().add(
      CreateFarmer(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        phone: formattedPhone,
        role: "BUYER",
      ),
    );
    
    setState(() {
      _showReview = false;
    });
  }

  void _goBackToEdit() {
    setState(() {
      _showReview = false;
    });
  }

  void _createFarmer() {
    if (!_validateForm()) return;
    _showReviewDialog();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToOtpVerification() {
    context.push(
      RouteName.verifyOtp,
      extra: {
        'identifier': _emailController.text.trim().toLowerCase(), 
        'purpose': 'SIGNUP'
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGrey,
      appBar: AppBar(
        title: const Text(
          'Create Farmer Account',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.goNamed(RouteName.home),
          tooltip: 'Back to Dashboard',
        ),
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is CreateFarmerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: primaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            _navigateToOtpVerification();
          } else if (state is RegistrationError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Stack(
          children: [
            // Main Content
            BlocBuilder<RegistrationBloc, RegistrationState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Icon
                      Icon(
                        Icons.person_add_alt_1,
                        size: 80,
                        color: primaryGreen.withOpacity(0.7),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Create New Farmer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the details to create a farmer account',
                        style: TextStyle(fontSize: 14, color: textGrey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Email Field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'farmer@example.com',
                                labelStyle: const TextStyle(color: textGrey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: primaryGreen,
                                ),
                                filled: true,
                                fillColor: softGrey,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Phone Field
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone',
                                hintText: '0912345678 or +251912345678',
                                labelStyle: const TextStyle(color: textGrey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.phone_outlined,
                                  color: primaryGreen,
                                ),
                                helperText: 'Enter Ethiopian phone number',
                                helperStyle: TextStyle(fontSize: 12, color: textGrey),
                                filled: true,
                                fillColor: softGrey,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Minimum 8 characters',
                                labelStyle: const TextStyle(color: textGrey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: primaryGreen,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: textGrey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: softGrey,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password Field
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: const TextStyle(color: textGrey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: primaryGreen,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: primaryGreen,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: textGrey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: softGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is RegistrationLoading
                              ? null
                              : _createFarmer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: state is RegistrationLoading
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
                                  "Review & Create",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),

            // Review Overlay
            if (_showReview)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Review Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.verified_user,
                                  color: primaryGreen,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Review Information',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: primaryGreen,
                                      ),
                                    ),
                                    Text(
                                      'Please verify the details before creating',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Review Details Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardGrey,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildReviewItem(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: _emailController.text.trim().toLowerCase(),
                                ),
                                const Divider(height: 24),
                                _buildReviewItem(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: _formatPhoneNumber(_phoneController.text),
                                ),
                                const Divider(height: 24),
                                _buildReviewItem(
                                  icon: Icons.lock_outline,
                                  label: 'Password',
                                  value: '••••••••',
                                ),
                                const Divider(height: 24),
                                _buildReviewItem(
                                  icon: Icons.badge_outlined,
                                  label: 'Role',
                                  value: 'FARMER',
                                  valueColor: primaryGreen,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Warning Note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'An OTP will be sent to the email address for verification.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _goBackToEdit,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textGrey,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _confirmCreate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Confirm & Create'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryGreen),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}