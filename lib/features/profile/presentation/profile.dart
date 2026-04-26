import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_event.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_state.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_state.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:path_provider/path_provider.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
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
  bool _isCheckingProfile = true;
  String? _userId;

  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _checkIfUserHasProfile();
    context.read<RegistrationBloc>().add(LoadRegions());
  }

  void _checkIfUserHasProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _userId = authState.authResponse.user.id;
      context.read<ProfileBloc>().add(LoadProfile(userId: _userId!));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(RouteName.login);
      });
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
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File localImage = File(image.path);
        final File copiedImage = await localImage.copy(
          '${appDocDir.path}/$fileName',
        );

        setState(() {
          _selectedImage = copiedImage;
        });

        print('✅ Image saved permanently at: ${copiedImage.path}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      _showErrorSnackBar('Failed to pick image. Please try again.');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      PermissionStatus permission = await Permission.location.request();

      if (permission.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isGettingLocation = false;
        });

        _showSuccessSnackBar(
          'Location captured: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
        );

        print('📍 Current location: $_latitude, $_longitude');
      } else if (permission.isDenied) {
        setState(() {
          _isGettingLocation = false;
        });
        _showErrorSnackBar(
          'Location permission denied. Please enable location access.',
        );
      } else if (permission.isPermanentlyDenied) {
        setState(() {
          _isGettingLocation = false;
        });
        _showErrorSnackBar(
          'Location permission permanently denied. Please enable from settings.',
        );
        await openAppSettings();
      }
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
      print('❌ Error getting location: $e');
      _showErrorSnackBar(
        'Failed to get location. Please check GPS is enabled.',
      );
    }
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
    });
    _showSuccessSnackBar('Location cleared');
  }

  void _createProfile() {
    if (_nameController.text.isEmpty || selectedKebele == null) {
      _showErrorSnackBar('Please enter your name and select a kebele');
      return;
    }

    context.read<ProfileBloc>().add(
      CreateProfile(
        fullName: _nameController.text.trim(),
        kebeleId: selectedKebele!,
        image: _selectedImage,
        latitude: _latitude,
        longitude: _longitude,
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryGreen,
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
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              current is ProfileLoaded ||
              current is ProfileNotFound ||
              current is ProfileCreated ||
              current is ProfileError,
          listener: (context, state) {
            if (state is ProfileLoaded) {
              if (state.profile.profile != null) {
                print('✅ User has profile - redirecting to HOME');
                context.goNamed(RouteName.home);
                return;
              } else {
                setState(() => _isCheckingProfile = false);
              }
            } else if (state is ProfileNotFound) {
              print('ℹ️ User has no profile - showing create screen');
              setState(() => _isCheckingProfile = false);
            } else if (state is ProfileCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Profile created successfully'),
                  backgroundColor: primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              context.goNamed(RouteName.home);
            } else if (state is ProfileError) {
              if (state.message.contains('type \'Null\' is not a subtype') ||
                  state.message.contains('profile is null') ||
                  state.message.contains('User not found')) {
                print(
                  'ℹ️ User has no profile (from error) - showing create screen',
                );
                setState(() => _isCheckingProfile = false);
              } else {
                setState(() => _isCheckingProfile = false);
                _showErrorSnackBar(state.message);
              }
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
        buildWhen: (previous, current) =>
            current is ProfileLoading ||
            current is ProfileNotFound ||
            current is ProfileError,
        builder: (context, profileState) {
          if (profileState is ProfileLoading || _isCheckingProfile) {
            return const SizedBox.shrink();
          }

          return Scaffold(
            backgroundColor: softGrey,
            appBar: AppBar(
              title: const Text(
                'Create Profile',
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
              actions: [
                TextButton(
                  onPressed: _navigateToDashboard,
                  style: TextButton.styleFrom(foregroundColor: textGrey),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildFormSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(profileState),
                ],
              ),
            ),
          );
        },
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library, color: primaryGreen),
            label: const Text(
              'Add Photo',
              style: TextStyle(color: primaryGreen),
            ),
          ),
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
    } else {
      return Container(
        height: 120,
        width: 120,
        color: lightGreen,
        child: const Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
  }

  Widget _buildFormSection() {
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
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: const TextStyle(color: textGrey),
              hintText: 'Enter your full name',
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

  Widget _buildLocationSection() {
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
            'GPS Location (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your exact location to get accurate weather and farming recommendations',
            style: TextStyle(fontSize: 13, color: textGrey),
          ),
          const SizedBox(height: 16),

          if (_latitude != null && _longitude != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryGreen.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Location Captured',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Latitude:',
                              style: TextStyle(fontSize: 12, color: textGrey),
                            ),
                            Text(
                              _latitude!.toStringAsFixed(6),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Longitude:',
                              style: TextStyle(fontSize: 12, color: textGrey),
                            ),
                            Text(
                              _longitude!.toStringAsFixed(6),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearLocation,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear Location'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
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
                    : const Icon(Icons.my_location),
                label: Text(
                  _isGettingLocation
                      ? 'Getting Location...'
                      : 'Use Current Location',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
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
            onPressed: profileState is ProfileLoading ? null : _createProfile,
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
                    "Create Profile",
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
