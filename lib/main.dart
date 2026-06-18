import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_campus/firebase_options.dart';
import 'package:smart_campus/providers/announcement_provider.dart';
import 'package:smart_campus/providers/auth_provider.dart';
import 'package:smart_campus/providers/chat_provider.dart';
import 'package:smart_campus/providers/navigation_provider.dart';
import 'package:smart_campus/providers/weather_provider.dart';
import 'package:smart_campus/providers/theme_provider.dart';
import 'package:smart_campus/screens/announcements_screen.dart';
import 'package:smart_campus/screens/building_detail_screen.dart';
import 'package:smart_campus/screens/dashboard_screen.dart';
import 'package:smart_campus/screens/login_screen.dart';
import 'package:smart_campus/screens/register_screen.dart';
import 'package:smart_campus/screens/weather_screen.dart';
import 'package:smart_campus/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, themeProvider, _) {
          return MaterialApp(
            title: 'Smart Campus Assistant',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,

            initialRoute: auth.isLoggedIn ? '/dashboard' : '/login',
            onGenerateRoute: (settings) {
              if (settings.name == '/login' && auth.isLoggedIn) {
                return MaterialPageRoute(
                  builder: (_) => const DashboardScreen(),
                  settings: const RouteSettings(name: '/dashboard'),
                );
              }

              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                    settings: settings,
                  );
                case '/register':
                  return MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                    settings: settings,
                  );
                case '/dashboard':
                  return MaterialPageRoute(
                    builder: (_) => const DashboardScreen(),
                    settings: settings,
                  );
                case '/weather':
                  return MaterialPageRoute(
                    builder: (_) => const WeatherScreen(),
                    settings: settings,
                  );
                case '/announcements':
                  return MaterialPageRoute(
                    builder: (_) => const AnnouncementsScreen(),
                    settings: settings,
                  );
                case '/building':
                  return MaterialPageRoute(
                    builder: (_) => const BuildingDetailScreen(),
                    settings: settings,
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                    settings: settings,
                  );
              }
            },
          );
        },
      ),
    );
  }
}
