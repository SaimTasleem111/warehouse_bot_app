import 'package:flutter/material.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../widgets/bottom_navbar.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final token = await TokenStorage.getToken();
    final email = await TokenStorage.getUserEmail();
    final name = await TokenStorage.getUserName();

    // DEBUG LOGS
    print('🔍 DEBUG Splash Screen:');
    print('Token: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}');
    print('Email: $email');
    print('Name: $name');
    print('Is Logged In: ${token != null && token.isNotEmpty}');

    if (token != null && token.isNotEmpty) {
      print('✅ User is logged in - Going to Dashboard');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BottomNav(currentIndex: 0),
        ),
      );
    } else {
      print('❌ User is NOT logged in - Going to Login Screen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF1A1F2E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "WarehouseBot",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
