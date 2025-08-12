import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../globals.dart';
import 'ancestry_management_page.dart';
import 'template_manager_page.dart';

class AdminPanel extends ConsumerWidget {
  static const routeName = '/admin-panel';
  
  const AdminPanel({super.key});

  // List of authorized admin emails
  static const List<String> _authorizedAdmins = [
    'mathemagician@gmail.com',
    'sycrim@gmail.com',
  ];

  bool _isAuthorized(User? user) {
    if (user?.email == null) return false;
    return _authorizedAdmins.contains(user!.email!.toLowerCase());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (!_isAuthorized(user)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Administrator Access Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You do not have permission to access this panel.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Panel'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 32,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, Administrator',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Logged in as: ${user?.email ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Firebase Management Tools',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildAdminCard(
                    context,
                    title: 'Ancestry Management',
                    description: 'Manage ancestry data and upload to Firebase',
                    icon: Icons.people_outline,
                    color: Colors.blue,
                    onTap: () => navigatorKey.currentState?.pushNamed(
                      AncestryManagementPage.routeName,
                    ),
                  ),
                  _buildAdminCard(
                    context,
                    title: 'Template Manager',
                    description: 'Manage description templates and upload to Firebase',
                    icon: Icons.description,
                    color: Colors.green,
                    onTap: () => navigatorKey.currentState?.pushNamed(
                      TemplateManagerPage.routeName,
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

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}