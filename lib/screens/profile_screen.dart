import 'package:flutter/material.dart';
import 'package:smart_campus/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('John Doe', style: theme.textTheme.displayMedium),
                const SizedBox(height: 4),
                Text('BS Computer Science', style: theme.textTheme.bodyMedium),
                Text('ID: 19-NTU-CS-1122', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _ProfileOption(icon: Icons.settings, title: 'Settings', onTap: () {}),
          _ProfileOption(icon: Icons.notifications, title: 'Notifications', onTap: () {}),
          _ProfileOption(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
