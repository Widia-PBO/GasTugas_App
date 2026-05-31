import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart'; // Pastikan file ini ada di folder providers
import 'firebase_options.dart'; // Dibuat otomatis oleh FlutterFire CLI
import 'pages/splash_screen.dart';
import 'pages/dashboard.dart';
import 'pages/reminder.dart';
import 'pages/profile.dart';

void main() async {
  // Pastikan binding Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase agar fitur Auth bisa jalan
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()..cekSessionLogin()),
      ],
      child: const GasTugasApp(),
    ),
  );
}

class GasTugasApp extends StatelessWidget {
  const GasTugasApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GasTugas',
      theme: ThemeData(
        primaryColor: const Color(0xFF7B3FF2),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Pastikan file ini sudah ada di folder pages
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Memantau perubahan dari provider
    context.watch<AppProvider>();
    context.watch<AuthProvider>(); 

    final List<Widget> pages = [
      DashboardPage(
        onNavigateToTab: (index) {
          setState(() {
            _selectedIndex = index; 
          });
        },
      ),
      const ReminderPage(),
      const ProfilePage(), 
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B3FF2).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF7B3FF2),
          unselectedItemColor: Colors.black26,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), activeIcon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.alarm_rounded), activeIcon: Icon(Icons.alarm_rounded), label: 'Reminder'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}