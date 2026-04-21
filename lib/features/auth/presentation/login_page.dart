import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/core/localization/generated/app_localizations.dart';
import 'package:agrilink/core/localization/language_bloc.dart';
import 'package:agrilink/core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/injector.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

class DebugUser {
  final String role;
  final String email;
  final String password;

  DebugUser({required this.role, required this.email, required this.password});
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<DebugUser> _debugUsers = [
    DebugUser(
      role: "Agent",
      email: "meronmulu2121@gmail.com",
      password: "me4545",
    ),
    DebugUser(
      role: "Admin",
      email: "jidhaguta45@gmail.com",
      password: "87654321",
    ),
    DebugUser(
      role: "Farmer",
      email: "gemedatechnology@gmail.com",
      password: "securepass",
    ),
     DebugUser(
      role: "Buyer",
      email: "caalaaturee1@gmail.com",
      password: "Gammee",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkNotificationStatus();
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

  Future<void> _checkNotificationStatus() async {
    try {
      final notificationService = sl<NotificationService>();
      final token = await notificationService.getSavedToken();

      if (token != null) {
        debugPrint('✅ FCM Token exists: ${token.substring(0, 10)}...');
      } else {
        debugPrint('⏳ FCM Token not yet available, will be generated');
      }
    } catch (e) {
      debugPrint('❌ Notification check failed: $e');
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getCurrentLanguageCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  void _showLanguageSelector(BuildContext context) {
    final currentLanguage = _getCurrentLanguageCode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A2F),
                ),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                context,
                languageCode: 'en',
                languageName: 'English',
                nativeName: 'English',
                flag: '🇬🇧',
                isSelected: currentLanguage == 'en',
              ),
              const Divider(height: 1),
              _buildLanguageOption(
                context,
                languageCode: 'am',
                languageName: 'Amharic',
                nativeName: 'አማርኛ',
                flag: '🇪🇹',
                isSelected: currentLanguage == 'am',
              ),
              const Divider(height: 1),
              _buildLanguageOption(
                context,
                languageCode: 'om',
                languageName: 'Oromo',
                nativeName: 'Oromoo',
                flag: '🇪🇹',
                isSelected: currentLanguage == 'om',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        final languageBloc = context.read<LanguageBloc>();
        languageBloc.add(ChangeLanguage(Locale(languageCode)));
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $languageName'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context)!;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              context.go(RouteName.splash);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.green.shade700,
                            ),
                            tooltip: 'Back to Splash',
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: _showNotificationDiagnostic,
                                icon: Icon(
                                  Icons.notifications_active,
                                  color: Colors.orange.shade700,
                                ),
                                tooltip: 'Test Notifications',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () => _showLanguageSelector(context),
                                icon: Icon(
                                  Icons.language,
                                  color: Colors.green.shade700,
                                ),
                                tooltip: localizations.selectLanguage,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildHeader(localizations),
                    const SizedBox(height: 30),
                    _buildLoginForm(authBloc, localizations),
                    const SizedBox(height: 20),
                    _buildFooter(localizations),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNotificationDiagnostic() async {
    final notificationService = sl<NotificationService>();

    final token = await notificationService.getSavedToken();
    final permissions = await notificationService.getNotificationSettings();

    final safeTokenPreview = (token != null && token.isNotEmpty)
        ? (token.length > 20 ? '${token.substring(0, 20)}...' : token)
        : 'Not available';

    final tokenStatus = token != null ? '✅' : '❌';

    final permissionStatus = permissions.authorizationStatus == AuthorizationStatus.authorized
        ? '✅'
        : '❌';

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔔 Notification Diagnostic',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildDiagnosticRow('FCM Token', tokenStatus, safeTokenPreview),
              _buildDiagnosticRow(
                'Permission',
                permissionStatus,
                permissions.authorizationStatus.name,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await notificationService.localNotifications.show(
                      DateTime.now().millisecondsSinceEpoch.remainder(100000),
                      'Test Notification',
                      'Your notifications are working! ✅',
                      const NotificationDetails(
                        android: AndroidNotificationDetails(
                          'general_channel',
                          'General Notifications',
                          importance: Importance.high,
                          priority: Priority.high,
                        ),
                        iOS: DarwinNotificationDetails(),
                      ),
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  label: const Text('Send Test Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Text(
                'Note: FCM token is registered after login and synced with backend.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticRow(String label, String status, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(status, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              detail,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade700],
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
            Icons.agriculture_rounded,
            size: 70,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          localizations.welcomeBack,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A2F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.signInSubtitle,
          style: const TextStyle(fontSize: 16, color: Color(0xFF5E6D5C)),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthBloc authBloc, AppLocalizations localizations) {
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
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<DebugUser>(
                  decoration: InputDecoration(
                    labelText: localizations.quickDebugLogin,
                    prefixIcon: const Icon(
                      Icons.bug_report_outlined,
                      color: Colors.green,
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
                      borderSide: BorderSide(
                        color: Colors.green.shade600,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colors.green,
                  ),
                  isExpanded: true,
                  hint: Text(
                    localizations.selectTestAccount,
                    overflow: TextOverflow.ellipsis,
                  ),
                  items: _debugUsers.map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text(
                        "${user.role} - ${user.email}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (user) {
                    setState(() {
                      _identifierController.text = user!.email;
                      _passwordController.text = user.password;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.green,
                  ),
                  labelText: localizations.emailOrPhone,
                  hintText: localizations.emailOrPhoneHint,
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
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.emailOrPhoneRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.green,
                  ),
                  labelText: localizations.password,
                  hintText: localizations.passwordHint,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green,
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
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.passwordRequired;
                  }
                  if (value.length < 6) {
                    return localizations.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            localizations.rememberMe,
                            style: const TextStyle(color: Color(0xFF5E6D5C)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.goNamed(RouteName.forgotPassword);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                    ),
                    child: Text(localizations.forgotPassword),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    final user = state.authResponse.user;
                    final userStatus = user.status;
                    
                    debugPrint('✅ Login successful!');
                    debugPrint('   User Email: ${user.email}');
                    debugPrint('   User Status: $userStatus');
                    debugPrint('   User Role: ${user.role}');
                    
                    // Check if user is ACTIVE
                    if (userStatus == 'ACTIVE') {
                      // User is active - go to profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.welcomeMessage(user.email),
                          ),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      context.goNamed(RouteName.profile);
                    } else {
                      // User is NOT active (PENDING, INACTIVE, etc.) - go to OTP verification
                      debugPrint('⚠️ User is not active (Status: $userStatus). Redirecting to OTP verification...');
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please verify your account to continue.'),
                          backgroundColor: Colors.orange.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      
                      // Navigate to OTP verification page
                      context.goNamed(
                        RouteName.verifyOtp,
                        extra: {
                          "identifier": user.email,
                          "purpose": "VERIFICATION",
                        },
                      );
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
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final input = _identifierController.text.trim();
                                      final Map<String, dynamic> data = {
                                        "password": _passwordController.text.trim(),
                                      };

                                      if (input.contains('@')) {
                                        data["email"] = input;
                                      } else {
                                        data["phone"] = input;
                                      }

                                      authBloc.add(SignInEvent(data: data));
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
                                : Text(
                                    localizations.login,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: Colors.grey.shade400),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                localizations.orDivider,
                                style: const TextStyle(color: Color(0xFF5E6D5C)),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            icon: Image.asset(
                              'assets/images/google_logo.png',
                              height: 24,
                              width: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.red,
                                  size: 30,
                                );
                              },
                            ),
                            label: Text(
                              localizations.signInWithGoogle,
                              style: const TextStyle(
                                color: Color(0xFF1E3A2F),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    authBloc.add(GoogleSignInEvent());
                                  },
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

  Widget _buildFooter(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localizations.noAccount,
          style: const TextStyle(color: Color(0xFF5E6D5C)),
        ),
        TextButton(
          onPressed: () {
            context.goNamed(RouteName.signup);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
          child: Text(
            localizations.createAccount,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}