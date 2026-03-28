import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// Content
          SafeArea(
            child: BlocListener<RegistrationBloc, RegistrationState>(
              listener: (context, state) {
                if (state is RegionsLoaded) {
                  setState(() => regions = state.regions);
                }

                if (state is ZonesLoaded) {
                  setState(() {
                    zones = state.zones;
                    zonesEmpty = zones.isEmpty;
                  });
                }

                if (state is WoredasLoaded) {
                  setState(() {
                    woredas = state.woredas;
                    woredasEmpty = woredas.isEmpty;
                  });
                }

                if (state is KebelesLoaded) {
                  setState(() {
                    kebeles = state.kebeles;
                    kebelesEmpty = kebeles.isEmpty;
                  });
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
                        /// TOP BAR
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// CARD FORM
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                nameController,
                                "Full Name",
                                Icons.person,
                              ),
                              _buildTextField(
                                emailController,
                                "Email",
                                Icons.email,
                              ),
                              _buildTextField(
                                phoneController,
                                "Phone",
                                Icons.phone,
                              ),
                              _buildTextField(
                                passwordController,
                                "Password",
                                Icons.lock,
                                obscure: true,
                              ),

                              const SizedBox(height: 15),

                              _buildDropdown(
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

                              _buildDropdown(
                                hint: zonesEmpty
                                    ? "Coming Soon"
                                    : "Select Zone",
                                value: selectedZone,
                                items: zones,
                                onChanged:
                                    (selectedRegion == null || zonesEmpty)
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

                              _buildDropdown(
                                hint: woredasEmpty
                                    ? "Coming Soon"
                                    : "Select Woreda",
                                value: selectedWoreda,
                                items: woredas,
                                onChanged:
                                    (selectedZone == null || woredasEmpty)
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

                              _buildDropdown(
                                hint: kebelesEmpty
                                    ? "Coming Soon"
                                    : "Select Kebele",
                                value: selectedKebele,
                                items: kebeles,
                                onChanged:
                                    (selectedWoreda == null || kebelesEmpty)
                                    ? null
                                    : (value) {
                                        setState(() => selectedKebele = value);
                                      },
                              ),

                              const SizedBox(height: 25),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32)),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List items,
    required Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        hint: Text(hint),
        value: value,
        items: items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item['id'],
            child: Text(item['name']),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32)),
          ),
        ),
      ),
    );
  }
}
