import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedRegion;
  String? selectedZone;
  String? selectedWoreda;
  String? selectedKebele;

  List regions = [];
  List zones = [];
  List woredas = [];
  List kebeles = [];

  bool zonesEmpty = false;
  bool woredasEmpty = false;
  bool kebelesEmpty = false;

  @override
  void initState() {
    super.initState();
    context.read<RegistrationBloc>().add(LoadRegions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<RegistrationBloc, RegistrationState>(
          listener: (context, state) {
            if (state is RegionsLoaded) regions = state.regions;
            if (state is ZonesLoaded) {
              zones = state.zones;
              zonesEmpty = zones.isEmpty;
            }
            if (state is WoredasLoaded) {
              woredas = state.woredas;
              woredasEmpty = woredas.isEmpty;
            }
            if (state is KebelesLoaded) {
              kebeles = state.kebeles;
              kebelesEmpty = kebeles.isEmpty;
            }
            if (state is RegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Registration Successful")),
              );
            }
            if (state is RegistrationError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<RegistrationBloc, RegistrationState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: () => context.goNamed(RouteName.home),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTileTextField(
                            nameController,
                            "Full Name",
                            Icons.person,
                          ),
                          _buildTileTextField(
                            emailController,
                            "Email",
                            Icons.email,
                          ),
                          _buildTileTextField(
                            phoneController,
                            "Phone",
                            Icons.phone,
                          ),
                          _buildTileTextField(
                            passwordController,
                            "Password",
                            Icons.lock,
                            obscure: true,
                          ),
                          const SizedBox(height: 16),

                          _buildTileDropdown(
                            hint: "Select Region",
                            value: selectedRegion,
                            items: regions,
                            onChanged: (value) {
                              setState(() {
                                selectedRegion = value;
                                selectedZone = null;
                                selectedWoreda = null;
                                selectedKebele = null;
                                zones = [];
                                woredas = [];
                                kebeles = [];
                              });
                              context.read<RegistrationBloc>().add(
                                LoadZones(value!),
                              );
                            },
                          ),
                          _buildTileDropdown(
                            hint: zonesEmpty ? "Coming Soon" : "Select Zone",
                            value: selectedZone,
                            items: zones,
                            onChanged: (selectedRegion == null || zonesEmpty)
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedZone = value;
                                      selectedWoreda = null;
                                      selectedKebele = null;
                                      woredas = [];
                                      kebeles = [];
                                    });
                                    context.read<RegistrationBloc>().add(
                                      LoadWoredas(value!),
                                    );
                                  },
                          ),
                          _buildTileDropdown(
                            hint: woredasEmpty
                                ? "Coming Soon"
                                : "Select Woreda",
                            value: selectedWoreda,
                            items: woredas,
                            onChanged: (selectedZone == null || woredasEmpty)
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedWoreda = value;
                                      selectedKebele = null;
                                      kebeles = [];
                                    });
                                    context.read<RegistrationBloc>().add(
                                      LoadKebeles(value!),
                                    );
                                  },
                          ),
                          _buildTileDropdown(
                            hint: kebelesEmpty
                                ? "Coming Soon"
                                : "Select Kebele",
                            value: selectedKebele,
                            items: kebeles,
                            onChanged: (selectedWoreda == null || kebelesEmpty)
                                ? null
                                : (value) {
                                    setState(() => selectedKebele = value);
                                  },
                          ),

                          const SizedBox(height: 25),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                context.read<RegistrationBloc>().add(
                                  RegisterUser({
                                    "name": nameController.text,
                                    "email": emailController.text,
                                    "phone": phoneController.text,
                                    "password": passwordController.text,
                                    "regionId": selectedRegion,
                                    "zoneId": selectedZone,
                                    "woredaId": selectedWoreda,
                                    "kebeleId": selectedKebele,
                                  }),
                                );
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Tile Text Field
  Widget _buildTileTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.green[700]),
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.green.shade700),
            ),
          ),
        ),
      ),
    );
  }

  // Tile Dropdown
  Widget _buildTileDropdown({
    required String hint,
    required String? value,
    required List items,
    required Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: DropdownButtonFormField<String>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(hint),
          ),
          value: value,
          items: items.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item['id'],
              child: Text(item['name']),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.green.shade700),
            ),
          ),
        ),
      ),
    );
  }
}
