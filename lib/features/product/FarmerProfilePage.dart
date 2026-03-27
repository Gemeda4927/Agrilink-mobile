import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/auth/data/service/auth_service.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_event.dart';
import 'package:agrilink/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agrilink/injector.dart';

class FarmerProfilePage extends StatefulWidget {
  final String farmerId;

  const FarmerProfilePage({super.key, required this.farmerId});

  @override
  State<FarmerProfilePage> createState() => _FarmerProfilePageState();
}

class _FarmerProfilePageState extends State<FarmerProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile(userId: widget.farmerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return _buildLoadingState();
          }
          
          if (state is ProfileError) {
            return _buildErrorState(state.message);
          }
          
          if (state is ProfileNotFound) {
            return _buildNotFoundState();
          }

          if (state is ProfileLoaded) {
            final user = state.profile;
            final profile = user.profile;

            return CustomScrollView(
              slivers: [
                _buildHeader(user, profile),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildContactCard(user),
                        const SizedBox(height: 16),
                        if (profile?.kebele != null)
                          _buildLocationCard(profile!),
                        const SizedBox(height: 16),
                        _buildStatsCard(),
                        const SizedBox(height: 20),
                        _buildChatButton(user, profile),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(dynamic user, dynamic profile) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.green.shade700,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteName.home);
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade700,
                Colors.green.shade500,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: profile?.imageUrl != null
                      ? NetworkImage(profile!.imageUrl!)
                      : null,
                  child: profile?.imageUrl == null
                      ? Icon(Icons.person, size: 60, color: Colors.green)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  profile?.fullName ?? user.email.split('@')[0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(user.role),
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.role,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(dynamic user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.contact_phone, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  "Contact Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.email,
                  label: "Email",
                  value: user.email,
                ),
                if (user.phone.isNotEmpty)
                  _buildInfoTile(
                    icon: Icons.phone,
                    label: "Phone",
                    value: user.phone,
                  ),
                _buildInfoTile(
                  icon: Icons.person,
                  label: "Member Since",
                  value: _formatDate(user.createdAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(dynamic profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  "Location",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (profile.kebele != null) ...[
                  _buildInfoTile(
                    icon: Icons.location_city,
                    label: "Kebele",
                    value: profile.kebele!.name,
                  ),
                  if (profile.kebele!.woreda != null)
                    _buildInfoTile(
                      icon: Icons.map,
                      label: "Woreda",
                      value: profile.kebele!.woreda!.name,
                    ),
                  if (profile.kebele!.woreda?.zone != null)
                    _buildInfoTile(
                      icon: Icons.public,
                      label: "Zone",
                      value: profile.kebele!.woreda!.zone!.name,
                    ),
                  if (profile.kebele!.woreda?.zone?.region != null)
                    _buildInfoTile(
                      icon: Icons.flag,
                      label: "Region",
                      value: profile.kebele!.woreda!.zone!.region!.name,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.production_quantity_limits,
              label: "Products",
              value: "0",
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            _buildStatItem(
              icon: Icons.star,
              label: "Rating",
              value: "0",
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            _buildStatItem(
              icon: Icons.people,
              label: "Followers",
              value: "0",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
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
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(dynamic user, dynamic profile) {
    return ElevatedButton(
      onPressed: () async {
        final currentUser = await sl<AuthService>().getLoggedInUser();

        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please login to chat"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (currentUser.id == user.id) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You cannot chat with yourself"),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        context.push(
          RouteName.chat,
          extra: {
            'receiverId': user.id,
            'receiverName': profile?.fullName ?? user.email.split('@')[0],
            'receiverAvatar': profile?.imageUrl,
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 20),
          SizedBox(width: 8),
          Text(
            "Start Conversation",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              "Loading profile...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProfileBloc>().add(
                    LoadProfile(userId: widget.farmerId),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                "Profile Not Found",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "The farmer profile you're looking for doesn't exist or may have been removed.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.go(RouteName.home);
                },
                icon: const Icon(Icons.home),
                label: const Text("Go Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'FARMER':
        return Icons.agriculture;
      case 'BUYER':
        return Icons.shopping_cart;
      default:
        return Icons.person;
    }
  }


String _formatDate(dynamic date) {
  if (date == null) return 'Unknown';
  
  DateTime? dateTime;
  
  // Handle if date is a String
  if (date is String) {
    try {
      dateTime = DateTime.parse(date);
    } catch (e) {
      return 'Unknown';
    }
  } else if (date is DateTime) {
    dateTime = date;
  } else {
    return 'Unknown';
  }
  
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} years ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hours ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return 'Just now';
  }
}





}