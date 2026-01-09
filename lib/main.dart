import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

// Background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permissions
  await FirebaseMessaging.instance.requestPermission();

  // Subscribe to topic (REQUIRED - can't skip this)
  await FirebaseMessaging.instance.subscribeToTopic('all_users');
  
  print('✅ FCM Ready');

  runApp(const WarehouseBotApp());
}

class WarehouseBotApp extends StatelessWidget {
  const WarehouseBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WarehouseBot App",
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}