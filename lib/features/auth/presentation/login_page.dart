import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
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

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

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
  ];

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - MediaQuery.of(context).padding.top,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture, size: 80, color: Colors.green),
                  const SizedBox(height: 16),

                  const Text(
                    "Welcome Back!",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Login using email or phone",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// DEBUG LOGIN DROPDOWN
                        DropdownButtonFormField<DebugUser>(
                          decoration: InputDecoration(
                            labelText: "Quick Debug Login",
                            prefixIcon: const Icon(Icons.bug_report),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _debugUsers.map((user) {
                            return DropdownMenuItem(
                              value: user,
                              child: Text("${user.role} (${user.email})"),
                            );
                          }).toList(),
                          onChanged: (user) {
                            setState(() {
                              _identifierController.text = user!.email;
                              _passwordController.text = user.password;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        /// EMAIL OR PHONE
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline),
                            labelText: "Email or Phone",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter email or phone";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// PASSWORD
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
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

                        const SizedBox(height: 10),

                        /// FORGOT PASSWORD
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.goNamed(RouteName.forgotPassword);
                            },
                            child: const Text("Forgot Password?"),
                          ),
                        ),

                        const SizedBox(height: 16),

                        BlocListener<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Welcome ${state.authResponse.user.email}",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              context.goNamed(RouteName.home);
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
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const CircularProgressIndicator();
                              }

                              return Column(
                                children: [
                                  /// LOGIN BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          final input = _identifierController
                                              .text
                                              .trim();

                                          final Map<String, dynamic> data = {
                                            "password": _passwordController.text
                                                .trim(),
                                          };

                                          if (input.contains('@')) {
                                            data["email"] = input;
                                          } else {
                                            data["phone"] = input;
                                          }

                                          authBloc.add(SignInEvent(data: data));
                                        }
                                      },
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Row(
                                    children: [
                                      Expanded(child: Divider()),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text("OR"),
                                      ),
                                      Expanded(child: Divider()),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  /// GOOGLE LOGIN
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.g_mobiledata,
                                        color: Colors.red,
                                      ),
                                      label: const Text("Sign in with Google"),
                                      onPressed: () {
                                        authBloc.add(GoogleSignInEvent());
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  /// SIGNUP
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Don't have an account?"),

                                      TextButton(
                                        onPressed: () {
                                          context.goNamed(RouteName.signup);
                                        },
                                        child: const Text("Create Account"),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
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
}
