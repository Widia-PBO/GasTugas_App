import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../main.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _jalankanSplash();
  }

  Future<void> _jalankanSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    await provider.cekSessionLogin();
    if (!mounted) return;
    if (provider.isUserLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 220,
              errorBuilder: (c, e, s) => const Icon(
                Icons.book_rounded,
                size: 100,
                color: Color(0xFF7B3FF2),
              ),
            ),
            const SizedBox(height: 25),
            const CircularProgressIndicator(
              color: Color(0xFF7B3FF2),
            ),
          ],
        ),
      ),
    );
  }
}
