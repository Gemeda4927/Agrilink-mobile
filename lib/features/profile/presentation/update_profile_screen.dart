import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_event.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_state.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_state.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';

class UpdateProfileScreen extends StatefulWidget {
  final GetProfileModel existingProfile;

  const UpdateProfileScreen({super.key, required this.existingProfile});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

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

  // Color scheme
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    context.read<RegistrationBloc>().add(LoadRegions());
    _populateExistingData();
  }

  void _populateExistingData() {
    final profile = widget.existingProfile.profile!;

    _nameController.text = profile.fullName;
    _existingImageUrl = profile.imageUrl;

    if (profile.kebele != null) {
      selectedKebele = profile.kebele!.id;

      if (profile.kebele!.woreda != null) {
        selectedWoreda = profile.kebele!.woreda!.id;

        if (profile.kebele!.woreda!.zone != null) {
          selectedZone = profile.kebele!.woreda!.zone!.id;

          if (profile.kebele!.woreda!.zone!.region != null) {
            selectedRegion = profile.kebele!.woreda!.zone!.region!.id;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      // Silently handle error
    }
  }

  void _updateProfile() {
    if (_nameController.text.isEmpty || selectedKebele == null) {
      _showErrorSnackBar('Please enter your name and select a kebele');
      return;
    }

    context.read<ProfileBloc>().add(
      UpdateProfile(
        fullName: _nameController.text.trim(),
        kebeleId: selectedKebele!,
        image: _selectedImage,
      ),
    );
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

  void _navigateToDashboard() {
    context.goNamed(RouteName.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGrey,
      appBar: AppBar(
        title: const Text(
          'Update Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: _navigateToDashboard,
          tooltip: 'Back to Dashboard',
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('✅ Profile updated successfully'),
                    backgroundColor: primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                context.goNamed(RouteName.viewProfile);
              } else if (state is ProfileError) {
                _showErrorSnackBar(state.message);
              }
            },
          ),
          BlocListener<RegistrationBloc, RegistrationState>(
            listener: (context, state) {
              if (state is RegionsLoaded) {
                setState(() => regions = state.regions);
              } else if (state is ZonesLoaded) {
                setState(() {
                  zones = state.zones;
                  zonesEmpty = zones.isEmpty;
                });
              } else if (state is WoredasLoaded) {
                setState(() {
                  woredas = state.woredas;
                  woredasEmpty = woredas.isEmpty;
                });
              } else if (state is KebelesLoaded) {
                setState(() {
                  kebeles = state.kebeles;
                  kebelesEmpty = kebeles.isEmpty;
                });
              } else if (state is RegistrationError) {
                _showErrorSnackBar(state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Image Section
                  _buildImageSection(),
                  const SizedBox(height: 24),

                  // Form Section
                  _buildFormSection(profileState),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(profileState),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
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
          const Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              children: [
                // Image Display
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryGreen, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(child: _buildImageWidget()),
                ),
                // Camera Icon Overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library, color: primaryGreen),
            label: const Text(
              'Change Photo',
              style: TextStyle(color: primaryGreen),
            ),
          ),
          if (_existingImageUrl != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _existingImageUrl = null;
                });
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Remove Photo',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        height: 120,
        width: 120,
        fit: BoxFit.cover,
      );
    } else if (_existingImageUrl != null) {
      return Image.network(
        _existingImageUrl!,
        height: 120,
        width: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 120,
            width: 120,
            color: lightGreen,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 120,
            width: 120,
            color: lightGreen,
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          );
        },
      );
    } else {
      return Container(
        height: 120,
        width: 120,
        color: lightGreen,
        child: const Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
  }

  Widget _buildFormSection(ProfileState profileState) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 16),

          // Full Name Field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: const TextStyle(color: textGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryGreen, width: 2),
              ),
              prefixIcon: const Icon(Icons.person_outline, color: primaryGreen),
              filled: true,
              fillColor: softGrey,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Location Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 16),

          /// Region Dropdown
          _buildDropdownField(
            label: 'Region',
            icon: Icons.location_city_outlined,
            value: selectedRegion,
            items: regions,
            hint: 'Select Region',
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
              if (value != null) {
                context.read<RegistrationBloc>().add(LoadZones(value));
              }
            },
          ),
          const SizedBox(height: 12),

          /// Zone Dropdown
          _buildDropdownField(
            label: 'Zone',
            icon: Icons.map_outlined,
            value: selectedZone,
            items: zones,
            hint: zonesEmpty ? 'Coming Soon' : 'Select Zone',
            enabled: selectedRegion != null && !zonesEmpty,
            onChanged: (value) {
              setState(() {
                selectedZone = value;
                selectedWoreda = null;
                selectedKebele = null;
                woredas = [];
                kebeles = [];
                woredasEmpty = false;
                kebelesEmpty = false;
              });
              if (value != null) {
                context.read<RegistrationBloc>().add(LoadWoredas(value));
              }
            },
          ),
          const SizedBox(height: 12),

          /// Woreda Dropdown
          _buildDropdownField(
            label: 'Woreda',
            icon: Icons.zoom_out_map_outlined,
            value: selectedWoreda,
            items: woredas,
            hint: woredasEmpty ? 'Coming Soon' : 'Select Woreda',
            enabled: selectedZone != null && !woredasEmpty,
            onChanged: (value) {
              setState(() {
                selectedWoreda = value;
                selectedKebele = null;
                kebeles = [];
                kebelesEmpty = false;
              });
              if (value != null) {
                context.read<RegistrationBloc>().add(LoadKebeles(value));
              }
            },
          ),
          const SizedBox(height: 12),

          /// Kebele Dropdown
          _buildDropdownField(
            label: 'Kebele',
            icon: Icons.location_on_outlined,
            value: selectedKebele,
            items: kebeles,
            hint: kebelesEmpty ? 'Coming Soon' : 'Select Kebele',
            enabled: selectedWoreda != null && !kebelesEmpty,
            onChanged: (value) {
              setState(() => selectedKebele = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List items,
    required String hint,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        prefixIcon: Icon(icon, color: primaryGreen),
        filled: true,
        fillColor: enabled ? softGrey : Colors.grey[100],
      ),
      value: value,
      hint: Text(
        hint,
        style: TextStyle(color: enabled ? textGrey : Colors.grey),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: enabled ? primaryGreen : Colors.grey,
      ),
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item['id'],
          child: Text(
            item['name'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }

  Widget _buildActionButtons(ProfileState profileState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: profileState is ProfileLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: profileState is ProfileLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _navigateToDashboard,
            style: OutlinedButton.styleFrom(
              foregroundColor: textGrey,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Back to Dashboard",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
