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
      appBar: AppBar(title: const Text("Register")),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegionsLoaded) {
            setState(() {
              regions = state.regions;
            });
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
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 20),

                  /// REGION
                  DropdownButtonFormField<String>(
                    hint: const Text("Select Region"),
                    value: selectedRegion,
                    items: regions.map<DropdownMenuItem<String>>((region) {
                      return DropdownMenuItem<String>(
                        value: region['id'],
                        child: Text(region['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRegion = value;
                        selectedZone = null;
                        selectedWoreda = null;
                        selectedKebele = null;

                        zones = [];
                        woredas = [];
                        kebeles = [];

                        zonesEmpty = false;
                        woredasEmpty = false;
                        kebelesEmpty = false;
                      });

                      context.read<RegistrationBloc>().add(LoadZones(value!));
                    },
                  ),

                  const SizedBox(height: 10),

                  /// ZONE
                  DropdownButtonFormField<String>(
                    hint: Text(zonesEmpty ? "Coming Soon" : "Select Zone"),
                    value: selectedZone,
                    items: zones.map<DropdownMenuItem<String>>((zone) {
                      return DropdownMenuItem<String>(
                        value: zone['id'],
                        child: Text(zone['name']),
                      );
                    }).toList(),
                    onChanged: (selectedRegion == null || zonesEmpty)
                        ? null
                        : (value) {
                            setState(() {
                              selectedZone = value;
                              selectedWoreda = null;
                              selectedKebele = null;

                              woredas = [];
                              kebeles = [];

                              woredasEmpty = false;
                              kebelesEmpty = false;
                            });

                            context.read<RegistrationBloc>().add(
                              LoadWoredas(value!),
                            );
                          },
                  ),

                  const SizedBox(height: 10),

                  /// WOREDA
                  DropdownButtonFormField<String>(
                    hint: Text(woredasEmpty ? "Coming Soon" : "Select Woreda"),
                    value: selectedWoreda,
                    items: woredas.map<DropdownMenuItem<String>>((woreda) {
                      return DropdownMenuItem<String>(
                        value: woreda['id'],
                        child: Text(woreda['name']),
                      );
                    }).toList(),
                    onChanged: (selectedZone == null || woredasEmpty)
                        ? null
                        : (value) {
                            setState(() {
                              selectedWoreda = value;
                              selectedKebele = null;
                              kebeles = [];
                              kebelesEmpty = false;
                            });

                            context.read<RegistrationBloc>().add(
                              LoadKebeles(value!),
                            );
                          },
                  ),

                  const SizedBox(height: 10),

                  /// KEBELE
                  DropdownButtonFormField<String>(
                    hint: Text(kebelesEmpty ? "Coming Soon" : "Select Kebele"),
                    value: selectedKebele,
                    items: kebeles.map<DropdownMenuItem<String>>((kebele) {
                      return DropdownMenuItem<String>(
                        value: kebele['id'],
                        child: Text(kebele['name']),
                      );
                    }).toList(),
                    onChanged: (selectedWoreda == null || kebelesEmpty)
                        ? null
                        : (value) {
                            setState(() {
                              selectedKebele = value;
                            });
                          },
                  ),

                  const SizedBox(height: 30),

                  /// REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                      child: const Text("Register"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
