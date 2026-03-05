import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';

class VerifyOtpPage extends StatefulWidget {
  /// Pass email or phone from previous screen
  final String identifier;
  final String purpose; // SIGNUP | LOGIN | RESET

  const VerifyOtpPage({
    super.key,
    required this.identifier,
    this.purpose = "SIGNUP",
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height - kToolbarHeight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("OTP Verified!")),
                  );
                  context.goNamed(RouteName.home);
                }

                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)),
                  );
                }

                if (state is AuthMessage) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified, size: 80, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      "Verify your account",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Enter the 6-digit code sent to ${widget.identifier}",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    /// OTP Input
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "OTP Code",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value != null && value.length == 6
                          ? null
                          : "Enter valid 6-digit code",
                    ),
                    const SizedBox(height: 24),

                    /// VERIFY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                authBloc.add(
                                  VerifyOtpEvent(data: {
                                    "identifier": widget.identifier,
                                    "code": _codeController.text.trim(),
                                    "purpose": widget.purpose,
                                  }),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Verify OTP",
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Optionally implement resend OTP
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("OTP resent!")),
                        );
                      },
                      child: const Text("Resend OTP"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}