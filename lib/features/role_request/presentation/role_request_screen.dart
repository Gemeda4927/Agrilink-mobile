import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:agrilink/features/auth/domain/entities/auth_user.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_bloc.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_event.dart';
import 'package:agrilink/features/registration/presentation/bloc/registration_state.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_bloc.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_event.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleRequestScreen extends StatefulWidget {
  final AuthUserEntity? authUser;

  const RoleRequestScreen({super.key, this.authUser});

  @override
  State<RoleRequestScreen> createState() => _RoleRequestScreenState();
}

class _RoleRequestScreenState extends State<RoleRequestScreen> {
  // User Data
  AuthUserEntity? _authUser;
  String _currentUserRole = '';
  bool _isLoading = true;
  String _requestStatus = 'NONE';
  bool _canAccessRequest = false;

  // Location Data
  List _regions = [];
  List _zones = [];
  List _woredas = [];
  List _kebeles = [];

  String? _selectedRegionId;
  String? _selectedZoneId;
  String? _selectedWoredaId;
  String? _selectedKebeleId;
  
  // Location Names for Review
  String _selectedRegionName = '';
  String _selectedZoneName = '';
  String _selectedWoredaName = '';
  String _selectedKebeleName = '';

  // Form Data
  final _formKey = GlobalKey<FormState>();
  String _requestedRole = 'AGENT';
  String _currentRole = '';
  String _educationLevel = '';
  bool _experienceInAgriculture = true;
  bool _digitalSkills = true;
  bool _governmentAssigned = false;
  
  // File Upload
  List<File> _selectedFiles = [];
  List<String> _fileNames = [];
  List<String> _filePaths = [];

  // Dropdown Options
  final List<String> _requestedRoles = ['AGENT', 'DATA_CONTRIBUTOR'];
  final List<String> _currentRoles = ['DA_OFFICER', 'FARMER', 'OTHER'];
  final List<String> _educationLevels = [
    'NONE',
    'PRIMARY',
    'SECONDARY',
    'DIPLOMA',
    'DEGREE',
    'MASTERS',
    'PHD',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCurrentUserRole();
    _loadCachedRequestStatus();
    _loadRegions();
  }

  Future<void> _loadCurrentUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString('role');
      
      if (savedRole != null && savedRole.isNotEmpty) {
        setState(() {
          _currentUserRole = savedRole;
          _currentRole = savedRole;
          _canAccessRequest = (savedRole != 'ADMIN' && savedRole != 'AGENT');
        });
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
    }
  }

  Future<void> _loadCachedRequestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _requestStatus = prefs.getString('role_request_status') ?? 'NONE';
    });
  }

  void _loadUserData() {
    setState(() {
      _authUser = widget.authUser;
      _isLoading = false;
    });
  }

  void _loadRegions() {
    context.read<RegistrationBloc>().add(LoadRegions());
  }

  void _loadZones(String regionId) {
    context.read<RegistrationBloc>().add(LoadZones(regionId));
  }

  void _loadWoredas(String zoneId) {
    context.read<RegistrationBloc>().add(LoadWoredas(zoneId));
  }

  void _loadKebeles(String woredaId) {
    context.read<RegistrationBloc>().add(LoadKebeles(woredaId));
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );
      
      if (result != null) {
        setState(() {
          _selectedFiles = result.paths.map((path) => File(path!)).toList();
          _fileNames = result.files.map((file) => file.name).toList();
          _filePaths = result.paths.whereType<String>().toList();
        });
        _showSnackBar('${_selectedFiles.length} file(s) selected', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error picking files: $e', Colors.red);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileNames.removeAt(index);
      _filePaths.removeAt(index);
    });
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A8F5E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.reviews, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Review Your Request',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReviewSection('Personal Information', Icons.person),
                      const SizedBox(height: 12),
                      _buildReviewItem(Icons.badge, 'Full Name', _authUser?.email?.split('@').first ?? 'Not provided'),
                      _buildReviewItem(Icons.email, 'Email', _authUser?.email ?? 'Not provided'),
                      _buildReviewItem(Icons.phone, 'Phone', _authUser?.phone ?? 'Not provided'),
                      _buildReviewItem(Icons.verified_user, 'Current Role', _currentUserRole),
                      
                      const Divider(height: 24),
                      
                      _buildReviewSection('Location Information', Icons.location_on),
                      const SizedBox(height: 12),
                      _buildReviewItem(Icons.map, 'Region', _selectedRegionName.isNotEmpty ? _selectedRegionName : 'Not selected'),
                      _buildReviewItem(Icons.location_city, 'Zone', _selectedZoneName.isNotEmpty ? _selectedZoneName : 'Not selected'),
                      _buildReviewItem(Icons.location_city, 'Woreda', _selectedWoredaName.isNotEmpty ? _selectedWoredaName : 'Not selected'),
                      _buildReviewItem(Icons.home, 'Kebele', _selectedKebeleName.isNotEmpty ? _selectedKebeleName : 'Not selected'),
                      
                      const Divider(height: 24),
                      
                      _buildReviewSection('Role Request Details', Icons.assignment_turned_in),
                      const SizedBox(height: 12),
                      _buildReviewItem(Icons.verified_user, 'Requested Role', _requestedRole.replaceAll('_', ' ')),
                      _buildReviewItem(Icons.work, 'Current Role (Form)', _currentRole.replaceAll('_', ' ')),
                      _buildReviewItem(Icons.school, 'Education Level', _educationLevel),
                      _buildReviewItem(Icons.agriculture, 'Experience in Agriculture', _experienceInAgriculture ? 'Yes' : 'No'),
                      _buildReviewItem(Icons.computer, 'Digital Skills', _digitalSkills ? 'Yes' : 'No'),
                      _buildReviewItem(Icons.account_balance, 'Government Assigned', _governmentAssigned ? 'Yes' : 'No'),
                      
                      if (_fileNames.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildReviewSection('Verification Documents', Icons.attach_file),
                        const SizedBox(height: 12),
                        ..._fileNames.map((fileName) => _buildReviewItem(Icons.insert_drive_file, 'Document', fileName)),
                      ],
                    ],
                  ),
                ),
              ),
              // Footer Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _submitRequest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A8F5E),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Confirm Submit', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSection(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A8F5E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && _selectedKebeleId != null) {
      if (_filePaths.isEmpty) {
        _showSnackBar('Please upload verification documents', Colors.orange);
        return;
      }
      
      context.read<RoleRequestBloc>().add(
        CreateRoleRequestEvent(
          kebeleId: _selectedKebeleId!,
          experienceInAgriculture: _experienceInAgriculture,
          requestedRole: _requestedRole,
          currentRole: _currentRole,
          educationLevel: _educationLevel,
          digitalSkills: _digitalSkills,
          governmentAssigned: _governmentAssigned,
          filePaths: _filePaths,
        ),
      );
    } else if (_selectedKebeleId == null) {
      _showSnackBar('Please select your kebele', Colors.orange);
    }
  }

  Future<void> _saveRequestStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role_request_status', status);
    setState(() {
      _requestStatus = status;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canAccessRequest) {
      return _buildAccessDeniedScreen();
    }

    if (_requestStatus == 'PENDING') {
      return _buildStatusScreen(
        title: 'Request Pending',
        message: 'Your role request is being reviewed',
        subMessage: 'You will be notified once approved',
        icon: Icons.pending_actions,
        iconColor: Colors.orange,
      );
    }

    if (_requestStatus == 'APPROVED') {
      return _buildStatusScreen(
        title: 'Request Approved!',
        message: 'Congratulations! Your request has been approved',
        subMessage: 'You can now access new features',
        icon: Icons.check_circle,
        iconColor: Colors.green,
      );
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<RoleRequestBloc, RoleRequestState>(
          listener: (context, state) {
            if (state is RoleRequestSuccess) {
              _saveRequestStatus('PENDING');
              _showSnackBar(state.message, Colors.green);
              Navigator.pop(context);
            } else if (state is RoleRequestError) {
              if (state.message.toLowerCase().contains('already')) {
                _saveRequestStatus('PENDING');
              }
              _showSnackBar(state.message, Colors.red);
            }
          },
        ),
      ],
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, regState) {
          _updateLocationData(regState);
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              title: const Text('Request New Role'),
              elevation: 0,
              backgroundColor: const Color(0xFF1A8F5E),
              foregroundColor: Colors.white,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildUserInfoCard(),
                const SizedBox(height: 16),
                _buildLocationCard(),
                const SizedBox(height: 16),
                _buildRoleRequestCard(),
                const SizedBox(height: 16),
                _buildFileUploadCard(),
                const SizedBox(height: 16),
                _buildSubmitButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateLocationData(RegistrationState regState) {
    if (regState is RegionsLoaded) _regions = regState.regions;
    if (regState is ZonesLoaded) _zones = regState.zones;
    if (regState is WoredasLoaded) _woredas = regState.woredas;
    if (regState is KebelesLoaded) _kebeles = regState.kebeles;
  }

  Widget _buildAccessDeniedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Access Denied'),
        elevation: 0,
        backgroundColor: const Color(0xFFDC3545),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC3545).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  size: 60,
                  color: Color(0xFFDC3545),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC3545),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You are logged in as $_currentUserRole',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Role requests are only available for Farmers',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC3545),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A8F5E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF1A8F5E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoTile(Icons.badge_outlined, 'Full Name', _authUser?.email?.split('@').first ?? 'Not provided'),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.email_outlined, 'Email', _authUser?.email ?? 'Not provided'),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.phone_outlined, 'Phone', _authUser?.phone ?? 'Not provided'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A8F5E).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A8F5E).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: Color(0xFF1A8F5E), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Role',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _currentUserRole.isEmpty ? 'Loading...' : _currentUserRole,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A8F5E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF3498DB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Location Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Region',
              icon: Icons.map,
              value: _selectedRegionId,
              items: _regions,
              onChanged: (value) {
                setState(() {
                  _selectedRegionId = value;
                  _selectedRegionName = _getItemName(_regions, value);
                  _selectedZoneId = null;
                  _selectedWoredaId = null;
                  _selectedKebeleId = null;
                  _zones = [];
                  _woredas = [];
                  _kebeles = [];
                });
                if (value != null) _loadZones(value);
              },
            ),
            if (_zones.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Zone',
                icon: Icons.location_city,
                value: _selectedZoneId,
                items: _zones,
                onChanged: (value) {
                  setState(() {
                    _selectedZoneId = value;
                    _selectedZoneName = _getItemName(_zones, value);
                    _selectedWoredaId = null;
                    _selectedKebeleId = null;
                    _woredas = [];
                    _kebeles = [];
                  });
                  if (value != null) _loadWoredas(value);
                },
              ),
            ],
            if (_woredas.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Woreda',
                icon: Icons.location_city,
                value: _selectedWoredaId,
                items: _woredas,
                onChanged: (value) {
                  setState(() {
                    _selectedWoredaId = value;
                    _selectedWoredaName = _getItemName(_woredas, value);
                    _selectedKebeleId = null;
                    _kebeles = [];
                  });
                  if (value != null) _loadKebeles(value);
                },
              ),
            ],
            if (_kebeles.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Kebele',
                icon: Icons.home,
                value: _selectedKebeleId,
                items: _kebeles,
                onChanged: (value) {
                  setState(() {
                    _selectedKebeleId = value;
                    _selectedKebeleName = _getItemName(_kebeles, value);
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getItemName(List items, String? id) {
    if (id == null) return '';
    final item = items.firstWhere((item) => item['id'].toString() == id, orElse: () => null);
    return item != null ? item['name'].toString() : '';
  }

  Widget _buildRoleRequestCard() {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39C12).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in,
                      color: Color(0xFFF39C12),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Role Request Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDropdownField(
                label: 'Requested Role',
                icon: Icons.verified_user,
                value: _requestedRole,
                items: _requestedRoles.map((role) => {
                  'id': role,
                  'name': role.replaceAll('_', ' '),
                }).toList(),
                onChanged: (value) => setState(() => _requestedRole = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Current Role',
                icon: Icons.work,
                value: _currentRole,
                items: _currentRoles.map((role) => {
                  'id': role,
                  'name': role.replaceAll('_', ' '),
                }).toList(),
                onChanged: (value) => setState(() => _currentRole = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Education Level',
                icon: Icons.school,
                value: _educationLevel.isEmpty ? null : _educationLevel,
                items: _educationLevels.map((level) => {
                  'id': level,
                  'name': level,
                }).toList(),
                onChanged: (value) => setState(() => _educationLevel = value!),
              ),
              const SizedBox(height: 16),
              _buildSwitchField(
                title: 'Experience in Agriculture',
                subtitle: 'Do you have experience in agriculture?',
                value: _experienceInAgriculture,
                onChanged: (value) => setState(() => _experienceInAgriculture = value),
                icon: Icons.agriculture,
                color: const Color(0xFF27AE60),
              ),
              const SizedBox(height: 12),
              _buildSwitchField(
                title: 'Digital Skills',
                subtitle: 'Do you have digital skills?',
                value: _digitalSkills,
                onChanged: (value) => setState(() => _digitalSkills = value),
                icon: Icons.computer,
                color: const Color(0xFF3498DB),
              ),
              const SizedBox(height: 12),
              _buildSwitchField(
                title: 'Government Assigned',
                subtitle: 'Are you assigned by the government?',
                value: _governmentAssigned,
                onChanged: (value) => setState(() => _governmentAssigned = value),
                icon: Icons.account_balance,
                color: const Color(0xFF9B59B6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileUploadCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.attach_file,
                    color: Color(0xFFE74C3C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Verification Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Required',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Please upload verification documents (PDF, JPG, PNG, DOC, DOCX)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Select Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A8F5E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_fileNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ..._fileNames.asMap().entries.map((entry) {
                int index = entry.key;
                String fileName = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.red),
                        onPressed: () => _removeFile(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isSubmitting = context.watch<RoleRequestBloc>().state is RoleRequestCreating;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _showReviewDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A8F5E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.reviews, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Review & Submit Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<dynamic> items, 
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF7F8C8D)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A8F5E), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['id'].toString(),
            child: Text(item['name'].toString()),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildSwitchField({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusScreen({
    required String title,
    required String message,
    required String subMessage,
    required IconData icon,
    required Color iconColor,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Request Role'),
        elevation: 0,
        backgroundColor: const Color(0xFF1A8F5E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 60, color: iconColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                subMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A8F5E),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}