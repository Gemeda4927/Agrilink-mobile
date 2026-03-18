import 'package:agrilink/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_event.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_state.dart';
import 'package:agrilink/features/profile/data/model/ProfileModel.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  String? _userId;
  GetProfileModel? _currentProfile;

  @override
  void initState() {
    super.initState();
    _getUserIdAndLoadProfile();
  }

  void _getUserIdAndLoadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _userId = authState.authResponse.user.id;
      context.read<ProfileBloc>().add(LoadProfile(userId: _userId!));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        context.goNamed(RouteName.login);
      });
    }
  }

  void _navigateToUpdateProfile() {
    if (_currentProfile != null && _currentProfile!.profile != null) {
   
      context.pushNamed(
        RouteName.updateProfile,
        extra: _currentProfile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToUpdateProfile,
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _currentProfile = state.profile;
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            );
          } else if (state is ProfileLoaded) {
            final getProfileModel = state.profile;

            // Check if profile data exists
            if (getProfileModel.profile == null) {
              return _buildNoProfileView();
            }

            final profileData = getProfileModel.profile!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header with Image
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: profileData.imageUrl != null
                                ? NetworkImage(profileData.imageUrl!)
                                : null,
                            child: profileData.imageUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Basic Info
                  Text(
                    profileData.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getProfileModel.role.toUpperCase(),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Information Card
                  _buildSectionCard(
                    title: 'Contact Information',
                    icon: Icons.contact_phone,
                    children: [
                      _buildInfoRow(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: getProfileModel.phone,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: getProfileModel.email,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Information Card
                  _buildSectionCard(
                    title: 'Location Information',
                    icon: Icons.location_on,
                    children: [
                      _buildInfoRow(
                        icon: Icons.badge,
                        label: 'Kebele ID',
                        value: profileData.kebeleId,
                      ),
                      if (profileData.kebele != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.location_city,
                          label: 'Kebele Name',
                          value: profileData.kebele!.name,
                        ),
                        if (profileData.kebele!.woreda != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.map,
                            label: 'Woreda',
                            value: profileData.kebele!.woreda!.name,
                          ),
                        ],
                        if (profileData.kebele!.woreda?.zone != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.zoom_out_map,
                            label: 'Zone',
                            value: profileData.kebele!.woreda!.zone!.name,
                          ),
                        ],
                        if (profileData.kebele!.woreda?.zone?.region !=
                            null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.location_city,
                            label: 'Region',
                            value:
                                profileData.kebele!.woreda!.zone!.region!.name,
                          ),
                        ],
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account Information Card
                  _buildSectionCard(
                    title: 'Account Information',
                    icon: Icons.account_circle,
                    children: [
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'User ID',
                        value: getProfileModel.id,
                        isMonospace: true,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Member Since',
                        value: _formatDate(getProfileModel.createdAt),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.verified_user,
                        label: 'Account Status',
                        value: getProfileModel.status,
                        isStatus: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToUpdateProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProfileError) {
            // Check if error is because profile doesn't exist
            if (state.message.contains('type \'Null\' is not a subtype') ||
                state.message.contains('profile is null')) {
              return _buildNoProfileView();
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_userId != null) {
                              context.read<ProfileBloc>().add(
                                LoadProfile(userId: _userId!),
                              );
                            } else {
                              _getUserIdAndLoadProfile();
                            }
                          },
                          child: const Text('Retry'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            context.goNamed(RouteName.home);
                          },
                          child: const Text('Go Home'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No profile data available'));
        },
      ),
    );
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_off, size: 60, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Profile Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'You haven\'t created a profile yet.\nCreate one to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.goNamed(RouteName.profile);
                },
                icon: const Icon(Icons.person_add),
                label: const Text(
                  'Create Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.goNamed(RouteName.home);
              },
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMonospace = false,
    bool isStatus = false,
  }) {
    Color? valueColor;
    if (isStatus) {
      valueColor = value.toLowerCase() == 'active'
          ? Colors.green
          : Colors.orange;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: isMonospace ? 'monospace' : null,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Today';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutEvent());
                Navigator.pop(context);
                context.goNamed(RouteName.login);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}