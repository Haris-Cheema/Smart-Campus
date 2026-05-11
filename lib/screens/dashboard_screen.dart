import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/providers/announcement_provider.dart';
import 'package:smart_campus/providers/auth_provider.dart';
import 'package:smart_campus/providers/weather_provider.dart';
import 'package:smart_campus/screens/assistant_screen.dart';
import 'package:smart_campus/screens/navigation_screen.dart';
import 'package:smart_campus/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    // Fetch weather on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _HomeTab(),
      const NavigationScreen(),
      const AssistantScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: changeTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Navigate'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Assistant'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── HOME TAB ───────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final weather = context.watch<WeatherProvider>();
    final announcements = context.watch<AnnouncementProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<WeatherProvider>().fetchWeather(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good ${_greeting()}!', style: theme.textTheme.bodyMedium),
                      Text(
                        auth.currentUser?.name ?? 'Student',
                        style: theme.textTheme.displayMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final dashboard = context.findAncestorStateOfType<DashboardScreenState>();
                    dashboard?.changeTab(3);
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: auth.currentUser?.avatarUrl != null && auth.currentUser!.avatarUrl.isNotEmpty
                        ? (auth.currentUser!.avatarUrl.startsWith('http')
                            ? NetworkImage(auth.currentUser!.avatarUrl)
                            : FileImage(File(auth.currentUser!.avatarUrl)) as ImageProvider)
                        : null,
                    child: auth.currentUser?.avatarUrl == null || auth.currentUser!.avatarUrl.isEmpty
                        ? Icon(Icons.person, color: theme.colorScheme.primary)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weather Card
            _WeatherCard(weather: weather),
            const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: theme.textTheme.displaySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.navigation_rounded,
                    title: 'Navigate',
                    color: theme.colorScheme.primary,
                    onTap: () {
                      final dashboard = context.findAncestorStateOfType<DashboardScreenState>();
                      dashboard?.changeTab(1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.smart_toy_rounded,
                    title: 'Assistant',
                    color: theme.colorScheme.secondary,
                    onTap: () {
                      final dashboard = context.findAncestorStateOfType<DashboardScreenState>();
                      dashboard?.changeTab(2);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.campaign_rounded,
                    title: 'Notices',
                    color: const Color(0xFF28A745),
                    onTap: () => Navigator.pushNamed(context, '/announcements'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Announcements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Announcements', style: theme.textTheme.displaySmall),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/announcements'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...announcements.announcements.take(3).map(
              (a) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(a.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      a.status.toUpperCase(),
                      style: TextStyle(color: _statusColor(a.status), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(a.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF28A745);
      case 'urgent':
        return const Color(0xFFBA1A1A);
      case 'resolved':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

// ─── WEATHER CARD ───────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final WeatherProvider weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (weather.isLoading && weather.weatherData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text('Loading weather...', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }

    if (weather.error != null && weather.weatherData == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off, color: Colors.grey, size: 40),
          title: const Text('Weather unavailable'),
          subtitle: const Text('Tap to retry'),
          onTap: () => context.read<WeatherProvider>().fetchWeather(),
        ),
      );
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/weather'),
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(weather.weatherIcon, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Campus Weather', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text('${weather.currentTemp.round()}°C · ${weather.weatherDescription}',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('💧 ${weather.humidity.round()}%   💨 ${weather.windSpeed.round()} km/h',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── QUICK ACTION CARD ──────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
