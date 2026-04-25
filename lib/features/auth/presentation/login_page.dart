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
import 'package:go_router/go_router.dart';

class DebugUser {
  final String role;
  final String email;
  final String password;

  const DebugUser({
    required this.role,
    required this.email,
    required this.password,
  });
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Flag to prevent multiple registrations
  bool _isTokenRegistered = false;

  static const List<DebugUser> _debugUsers = [
    DebugUser(role: 'Agent', email: 'meronmulu2121@gmail.com', password: 'me4545'),
    DebugUser(role: 'Admin', email: 'jidhaguta45@gmail.com', password: '87654321'),
    DebugUser(role: 'Farmer', email: 'gemedatechnology@gmail.com', password: 'securepass'),
    DebugUser(role: 'Buyer', email: 'caalaaturee1@gmail.com', password: 'Gammee'),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => _buildLanguageSheet(currentLanguage),
    );
  }

  Widget _buildLanguageSheet(String currentLanguage) {
    return Padding(
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
            languageCode: 'en',
            languageName: 'English',
            nativeName: 'English',
            flag: '🇬🇧',
            isSelected: currentLanguage == 'en',
          ),
          const Divider(height: 1),
          _buildLanguageOption(
            languageCode: 'am',
            languageName: 'Amharic',
            nativeName: 'አማርኛ',
            flag: '🇪🇹',
            isSelected: currentLanguage == 'am',
          ),
          const Divider(height: 1),
          _buildLanguageOption(
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
  }

  Widget _buildLanguageOption({
    required String languageCode,
    required String languageName,
    required String nativeName,
    required String flag,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _changeLanguage(languageCode, languageName),
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

  void _changeLanguage(String languageCode, String languageName) {
    context.read<LanguageBloc>().add(ChangeLanguage(Locale(languageCode)));
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $languageName'),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _registerDeviceToken(AuthSuccess state) async {
    // Prevent multiple registrations
    if (_isTokenRegistered) return;
    
    final notificationService = sl<NotificationService>();
    final token = await notificationService.getSavedToken();
    
    if (token == null || token.isEmpty) return;
    
    final registered = await notificationService.registerDeviceToken(token);
    if (!registered) return;
    
    final role = state.authResponse.user.role;
    if (role != null && role.isNotEmpty) {
      final normalizedRole = role.toLowerCase().trim();
      await notificationService.subscribeToTopic('all_users');
      await notificationService.subscribeToTopic('role_$normalizedRole');
    }
    
    _isTokenRegistered = true;
  }

  void _showNotificationDiagnostic() async {
    final notificationService = sl<NotificationService>();
    final token = await notificationService.getSavedToken();
    final permissions = await notificationService.getNotificationSettings();

    final tokenStatus = token != null && token.isNotEmpty ? '✅' : '❌';
    final tokenPreview = token != null && token.isNotEmpty
        ? (token.length > 20 ? '${token.substring(0, 20)}...' : token)
        : 'Not available';
    
    final permissionStatus = permissions.authorizationStatus == AuthorizationStatus.authorized
        ? '✅' : '❌';

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔔 Notification Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDiagnosticRow('FCM Token', tokenStatus, tokenPreview),
            _buildDiagnosticRow('Permission', permissionStatus, permissions.authorizationStatus.name),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendTestNotification(notificationService),
                icon: const Icon(Icons.notifications_active),
                label: const Text('Send Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendTestNotification(NotificationService notificationService) async {
    await notificationService.showTestNotification();

    if (!mounted) return;
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String status, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = AppLocalizations.of(context)!;

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildTopBar(t),
                  const SizedBox(height: 20),
                  _buildHeader(t),
                  const SizedBox(height: 30),
                  _buildLoginForm(t),
                  const SizedBox(height: 20),
                  _buildFooter(t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconButton(
          icon: Icons.arrow_back,
          color: Colors.green.shade700,
          onPressed: () => context.go(RouteName.splash),
          tooltip: 'Back',
        ),
        Row(
          children: [
            _buildIconButton(
              icon: Icons.notifications_active,
              color: Colors.orange.shade700,
              onPressed: _showNotificationDiagnostic,
              tooltip: 'Diagnostic',
            ),
            const SizedBox(width: 8),
            _buildIconButton(
              icon: Icons.language,
              color: Colors.green.shade700,
              onPressed: () => _showLanguageSelector(context),
              tooltip: t.selectLanguage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
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
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildHeader(AppLocalizations t) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
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
          child: const Icon(Icons.agriculture_rounded, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          t.welcomeBack,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A2F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.signInSubtitle,
          style: const TextStyle(fontSize: 14, color: Color(0xFF5E6D5C)),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
              _buildDebugUserDropdown(t),
              const SizedBox(height: 20),
              _buildEmailField(t),
              const SizedBox(height: 16),
              _buildPasswordField(t),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              _buildLoginButton(t),
              const SizedBox(height: 20),
              _buildDivider(t),
              const SizedBox(height: 20),
              _buildGoogleButton(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebugUserDropdown(AppLocalizations t) {
    return DropdownButtonFormField<DebugUser>(
      decoration: InputDecoration(
        labelText: t.quickDebugLogin,
        prefixIcon: const Icon(Icons.bug_report_outlined, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.green),
      isExpanded: true,
      hint: Text(t.selectTestAccount, overflow: TextOverflow.ellipsis),
      items: _debugUsers.map((user) => DropdownMenuItem(
        value: user,
        child: Text('${user.role} - ${user.email}', overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (user) {
        if (user != null) {
          setState(() {
            _identifierController.text = user.email;
            _passwordController.text = user.password;
          });
        }
      },
    );
  }

  Widget _buildEmailField(AppLocalizations t) {
    return TextFormField(
      controller: _identifierController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person_outline, color: Colors.green),
        labelText: t.emailOrPhone,
        hintText: t.emailOrPhoneHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) => value == null || value.isEmpty ? t.emailOrPhoneRequired : null,
    );
  }

  Widget _buildPasswordField(AppLocalizations t) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
        labelText: t.password,
        hintText: t.passwordHint,
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.green),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return t.passwordRequired;
        if (value.length < 6) return t.passwordMinLength;
        return null;
      },
    );
  }

  Widget _buildLoginButton(AppLocalizations t) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          await _registerDeviceToken(state);
          _navigateAfterLogin(state, t);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: state is AuthLoading ? null : () => _handleLogin(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state is AuthLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(t.login, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    
    final input = _identifierController.text.trim();
    final data = {'password': _passwordController.text.trim()};
    
    if (input.contains('@')) {
      data['email'] = input;
    } else {
      data['phone'] = input;
    }
    
    context.read<AuthBloc>().add(SignInEvent(data: data));
  }

  void _navigateAfterLogin(AuthSuccess state, AppLocalizations t) {
    final user = state.authResponse.user;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.welcomeMessage(user.email)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    if (user.status == 'ACTIVE') {
      context.goNamed(RouteName.profile);
    } else {
      context.goNamed(
        RouteName.verifyOtp,
        extra: {'identifier': user.email, 'purpose': 'VERIFICATION'},
      );
    }
  }

  Widget _buildDivider(AppLocalizations t) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade400)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(t.orDivider, style: const TextStyle(color: Color(0xFF5E6D5C))),
        ),
        Expanded(child: Divider(color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildGoogleButton(AppLocalizations t) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            icon: Image.asset(
              'assets/images/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
            ),
            label: Text(t.signInWithGoogle, style: const TextStyle(color: Color(0xFF1E3A2F))),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: state is AuthLoading ? null : () => context.read<AuthBloc>().add(GoogleSignInEvent()),
          ),
        );
      },
    );
  }

  Widget _buildFooter(AppLocalizations t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(t.noAccount, style: const TextStyle(color: Color(0xFF5E6D5C))),
        TextButton(
          onPressed: () => context.goNamed(RouteName.signup),
          style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
          child: Text(t.createAccount, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}