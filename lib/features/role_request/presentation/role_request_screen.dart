// role_request_screen.dart
import 'package:agrilink/features/registration/domain/entities/user.dart';
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
  final User? user;

  const RoleRequestScreen({super.key, this.user});

  @override
  State<RoleRequestScreen> createState() => _RoleRequestScreenState();
}

class _RoleRequestScreenState extends State<RoleRequestScreen> {
  User? _user;
  bool _isLoading = true;
  String _requestStatus = 'NONE';

  List _regions = [];
  List _zones = [];
  List _woredas = [];
  List _kebeles = [];

  String? _selectedRegionId;
  String? _selectedZoneId;
  String? _selectedWoredaId;
  String? _selectedKebeleId;

  final _formKey = GlobalKey<FormState>();
  String _currentRole = 'FARMER';
  String _educationLevel = '';
  bool _experienceInAgriculture = true;
  bool _digitalSkills = true;
  bool _governmentAssigned = false;
  List<String> _filePaths = [];

  final List<String> _educationLevels = [
    'NONE',
    'PRIMARY',
    'SECONDARY',
    'DIPLOMA',
    'DEGREE',
    'MASTERS',
    'PHD',
  ];

  final List<String> _currentRoles = ['DA_OFFICER', 'FARMER', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCachedRequestStatus();
    _loadRegions();
  }

  Future<void> _loadCachedRequestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _requestStatus = prefs.getString('role_request_status') ?? 'NONE';
    });
  }

  void _loadUserData() {
    if (widget.user != null) {
      setState(() {
        _user = widget.user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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

  void _submitRequest() {
    if (_formKey.currentState!.validate() && _selectedKebeleId != null) {
      context.read<RoleRequestBloc>().add(
        CreateRoleRequestEvent(
          kebeleId: _selectedKebeleId!,
          experienceInAgriculture: _experienceInAgriculture,
          currentRole: _currentRole,
          educationLevel: _educationLevel,
          digitalSkills: _digitalSkills,
          governmentAssigned: _governmentAssigned,
          filePaths: _filePaths.isNotEmpty ? _filePaths : null,
        ),
      );
    } else if (_selectedKebeleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your kebele'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _saveRequestStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role_request_status', status);
    setState(() {
      _requestStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_requestStatus == 'PENDING') {
      return _buildPendingStatusScreen();
    }

    if (_requestStatus == 'APPROVED') {
      return _buildApprovedStatusScreen();
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<RoleRequestBloc, RoleRequestState>(
          listener: (context, state) {
            if (state is RoleRequestSuccess) {
              _saveRequestStatus('PENDING');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            } else if (state is RoleRequestError) {
              if (state.message.contains('already')) {
                _saveRequestStatus('PENDING');
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade400,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, regState) {
          return _buildRequestForm(context, regState);
        },
      ),
    );
  }

  Widget _buildRequestForm(BuildContext context, RegistrationState regState) {
    final isSubmitting =
        context.watch<RoleRequestBloc>().state is RoleRequestCreating;

    if (regState is RegionsLoaded) {
      _regions = regState.regions;
    }
    if (regState is ZonesLoaded) {
      _zones = regState.zones;
    }
    if (regState is WoredasLoaded) {
      _woredas = regState.woredas;
    }
    if (regState is KebelesLoaded) {
      _kebeles = regState.kebeles;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Request Agent Role'),
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildUserInfoCard(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 16),
              _buildRoleRequestCard(isSubmitting),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Full Name',
                  value: _user?.name ?? 'Not provided',
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: _user?.email ?? 'Not provided',
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: _user?.phone ?? 'Not provided',
                  iconColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Location Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownTile(
              label: 'Region',
              icon: Icons.map_outlined,
              value: _selectedRegionId,
              items: _regions,
              onChanged: (value) {
                setState(() {
                  _selectedRegionId = value;
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
              _buildDropdownTile(
                label: 'Zone',
                icon: Icons.location_city_outlined,
                value: _selectedZoneId,
                items: _zones,
                onChanged: (value) {
                  setState(() {
                    _selectedZoneId = value;
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
              _buildDropdownTile(
                label: 'Woreda',
                icon: Icons.location_city_outlined,
                value: _selectedWoredaId,
                items: _woredas,
                onChanged: (value) {
                  setState(() {
                    _selectedWoredaId = value;
                    _selectedKebeleId = null;
                    _kebeles = [];
                  });
                  if (value != null) _loadKebeles(value);
                },
              ),
            ],
            if (_kebeles.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDropdownTile(
                label: 'Kebele',
                icon: Icons.home_outlined,
                value: _selectedKebeleId,
                items: _kebeles,
                onChanged: (value) {
                  setState(() => _selectedKebeleId = value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required IconData icon,
    required String? value,
    required List items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item['id'].toString(),
            child: Text(
              item['name'],
              style: TextStyle(color: Colors.grey.shade800),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
      ),
    );
  }

  Widget _buildRoleRequestCard(bool isSubmitting) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Role Request Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownTile(
              label: 'Current Role',
              icon: Icons.work_outline,
              value: _currentRole,
              items: _currentRoles
                  .map(
                    (role) => {'id': role, 'name': role.replaceAll('_', ' ')},
                  )
                  .toList(),
              onChanged: (value) => setState(() => _currentRole = value!),
            ),
            const SizedBox(height: 16),
            _buildDropdownTile(
              label: 'Education Level',
              icon: Icons.school_outlined,
              value: _educationLevel.isEmpty ? null : _educationLevel,
              items: _educationLevels
                  .map((level) => {'id': level, 'name': level})
                  .toList(),
              onChanged: (value) => setState(() => _educationLevel = value!),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Experience in Agriculture',
              subtitle: 'Do you have experience in agriculture?',
              value: _experienceInAgriculture,
              onChanged: (value) =>
                  setState(() => _experienceInAgriculture = value),
              icon: Icons.agriculture,
              color: Colors.green,
            ),
            _buildSwitchTile(
              title: 'Digital Skills',
              subtitle: 'Do you have digital skills?',
              value: _digitalSkills,
              onChanged: (value) => setState(() => _digitalSkills = value),
              icon: Icons.computer,
              color: Colors.blue,
            ),
            _buildSwitchTile(
              title: 'Government Assigned',
              subtitle: 'Are you assigned by the government?',
              value: _governmentAssigned,
              onChanged: (value) => setState(() => _governmentAssigned = value),
              icon: Icons.account_balance,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Submit Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
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
            activeTrackColor: color.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatusScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Request Agent Role'),
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade100,
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
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pending_actions,
                  size: 60,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Request Pending',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Your role request is currently pending approval.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'You will be notified once your request is reviewed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Go Back', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedStatusScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Request Agent Role'),
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade100,
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
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Request Approved!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Congratulations! Your role request has been approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
