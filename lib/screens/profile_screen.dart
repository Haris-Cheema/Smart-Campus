import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/providers/auth_provider.dart';
import 'package:smart_campus/widgets/loading_overlay.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showEditDialog() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final deptCtrl = TextEditingController(text: user.department);
    final idCtrl = TextEditingController(text: user.studentId);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  validator: AuthProvider.validateName,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: idCtrl,
                  validator: AuthProvider.validateStudentId,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: deptCtrl,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final success = await auth.updateProfile(
        name: nameCtrl.text.trim(),
        department: deptCtrl.text.trim(),
        studentId: idCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Profile updated!' : 'Update failed')),
        );
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return LoadingOverlay(
      isLoading: auth.isLoading,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      _initials(user?.name ?? 'S'),
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showEditDialog,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(user?.name ?? 'Student', style: theme.textTheme.displayMedium),
                  const SizedBox(height: 4),
                  Text(user?.department ?? '', style: theme.textTheme.bodyMedium),
                  Text('ID: ${user?.studentId ?? ''}', style: theme.textTheme.bodyMedium),
                  Text(user?.email ?? '', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _ProfileTile(icon: Icons.edit, title: 'Edit Profile', onTap: _showEditDialog),
            _ProfileTile(icon: Icons.campaign, title: 'Announcements', onTap: () => Navigator.pushNamed(context, '/announcements')),
            _ProfileTile(icon: Icons.wb_sunny, title: 'Weather', onTap: () => Navigator.pushNamed(context, '/weather')),
            _ProfileTile(icon: Icons.info_outline, title: 'About App', onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Smart Campus',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.school, color: theme.colorScheme.primary, size: 40),
                children: [const Text('NTU Faisalabad Smart Campus Navigation & Assistant App.')],
              );
            }),

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'S';
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ProfileTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: theme.textTheme.bodyLarge),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
