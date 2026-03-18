import 'package:agrilink/core/config/routes/route_name.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agrilink/features/auth/presentation/bloc/auth_state.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_bloc.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_event.dart';
import 'package:agrilink/features/category/presentation/bloc/categories_state.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_bloc.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_event.dart';
import 'package:agrilink/features/role_request/presentation/bloc/role_request_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.goNamed(RouteName.login),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return const Center(
                child: Text('No user data found. Please login.'),
              );
            }

            final user = authState.authResponse.user;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.email}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is CategoryLoaded) {
                          return _buildCategoryList(context, state);
                        }

                        if (state is SubCategoryLoaded) {
                          return _buildSubCategoryList(context, state);
                        }

                        if (state is CategoryError) {
                          return Center(child: Text(state.message));
                        }

                        return const SizedBox();
                      },
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

  /// Drawer
  Drawer _buildDrawer(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String role = "";
    if (authState is AuthSuccess) {
      role = authState.authResponse.user.role;
    }

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.goNamed(RouteName.home),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Product'),
            onTap: () => context.goNamed(RouteName.product),
          ),
          // ListTile(
          //   leading: const Icon(Icons.person),
          //   title: const Text('Profile'),
          //   onTap: () => context.goNamed(RouteName.profile),
          // ),

          // Show role status / request only for non-AGENT & non-ADMIN
          if (role == 'AGENT')
            const ListTile(
              leading: Icon(Icons.handshake),
              title: Text('Role: AGENT'),
            )
          else if (role != 'ADMIN')
            BlocConsumer<RoleRequestBloc, RoleRequestState>(
              listener: (context, state) {
                if (state is RoleRequestError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is RoleRequestSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Request Status: ${state.status}')),
                  );
                }
              },
              builder: (context, state) {
                String title = 'Join as Agent';

                if (state is RoleRequestLoading) {
                  title = 'Sending request...';
                } else if (state is RoleRequestSuccess) {
                  title = 'Status: ${state.status}';
                }

                return ListTile(
                  leading: const Icon(Icons.handshake),
                  title: Text(title),
                  onTap: state is RoleRequestLoading
                      ? null
                      : () {
                          context.read<RoleRequestBloc>().add(
                                CreateRoleRequestEvent(),
                              );
                        },
                );
              },
            ),
        ],
      ),
    );
  }

  /// Category List
  Widget _buildCategoryList(BuildContext context, CategoryLoaded state) {
    return ListView.builder(
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];

        return Card(
          child: ListTile(
            leading: const Icon(Icons.category),
            title: Text(category.name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.read<CategoryBloc>().add(LoadSubCategories(category.id));
            },
          ),
        );
      },
    );
  }

  /// SubCategory List
  Widget _buildSubCategoryList(BuildContext context, SubCategoryLoaded state) {
    final subs = state.subCategories;

    if (subs.isEmpty) {
      return const Center(child: Text("No subcategories found"));
    }

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.read<CategoryBloc>().add(LoadCategories());
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text("Back to Categories"),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];

              return Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.label),
                  title: Text(sub.name),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}