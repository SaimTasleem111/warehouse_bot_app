import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _notificationKey = 'notifications_enabled';
  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  NotificationProvider() {
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationKey) ?? true;
    
    // Sync with Firebase subscription on app start
    if (_notificationsEnabled) {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      print('🔔 Notifications enabled - Subscribed to Firebase');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
      print('🔕 Notifications disabled - Unsubscribed from Firebase');
    }
    
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, _notificationsEnabled);
    
    // Subscribe/Unsubscribe from Firebase topic based on preference
    if (_notificationsEnabled) {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      print('🔔 Notifications enabled - Subscribed to Firebase');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
      print('🔕 Notifications disabled - Unsubscribed from Firebase');
    }
    
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, enabled);
    
    // Subscribe/Unsubscribe from Firebase
    if (enabled) {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
      print('🔔 Notifications enabled - Subscribed to Firebase');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
      print('🔕 Notifications disabled - Unsubscribed from Firebase');
    }
    
    notifyListeners();
  }

  // Get FCM token (useful for device-specific notifications)
  Future<String?> getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('📱 FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }
}
