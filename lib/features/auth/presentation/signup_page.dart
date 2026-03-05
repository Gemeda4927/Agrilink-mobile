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

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String role = 'BUYER'; // default role

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            

context.goNamed(
  RouteName.verifyOtp,
  extra: {
    "identifier": emailController.text.trim(), 
    "purpose": "SIGNUP", 
  },
);

            }

            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// EMAIL
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value != null && value.contains("@")
                            ? null
                            : "Enter a valid email",
                  ),
                  const SizedBox(height: 10),

                  /// PHONE
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value != null && value.isNotEmpty
                            ? null
                            : "Enter phone number",
                  ),
                  const SizedBox(height: 10),

                  /// PASSWORD
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (value) =>
                        value != null && value.length >= 6
                            ? null
                            : "Password must be at least 6 characters",
                  ),
                  const SizedBox(height: 10),

                  /// CONFIRM PASSWORD
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration:
                        const InputDecoration(labelText: "Confirm Password"),
                    obscureText: true,
                    validator: (value) => value != null &&
                            value == passwordController.text
                        ? null
                        : "Passwords do not match",
                  ),
                  const SizedBox(height: 10),

                  /// ROLE SELECTION
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: "BUYER", child: Text("BUYER")),
                      DropdownMenuItem(value: "SELLER", child: Text("SELLER")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          role = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Role",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// SIGNUP BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          authBloc.add(SignUpEvent(data: {
                            "role": role,
                            "email": emailController.text.trim(),
                            "phone": phoneController.text.trim(),
                            "password": passwordController.text.trim(),
                            "confirmPassword":
                                confirmPasswordController.text.trim(),
                          }));
                        }
                      },
                      child: const Text("Create Account"),
                    ),
                  ),

                  /// LOGIN LINK
                  TextButton(
                    onPressed: () {
                      context.goNamed(RouteName.login);
                    },
                    child: const Text("Already have an account? Login"),
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