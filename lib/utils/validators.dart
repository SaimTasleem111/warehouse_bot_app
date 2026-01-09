/*import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class Validators {
  // -----------------------------
  // Email Validation
  // -----------------------------
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // -----------------------------
  // Password Validation
  // -----------------------------
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // -----------------------------
  // JWT Token Validation
  // -----------------------------
  static String? validateTokenFormat(String? token) {
    if (token == null || token.isEmpty) {
      return "Token not found. Please login again.";
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return "Invalid token structure.";
      }

      final payload = jsonDecode(
        utf8.decode(
          base64Url.decode(
            base64Url.normalize(parts[1]),
          ),
        ),
      );

      if (payload['exp'] == null) {
        return "Token missing expiry.";
      }

      final expiry = DateTime.fromMillisecondsSinceEpoch(
        payload['exp'] * 1000,
      );

      if (expiry.isBefore(DateTime.now())) {
        return "Session expired. Please login again.";
      }

      return null; // Valid token
    } catch (e) {
      return "Corrupted or invalid token.";
    }
  }
}

// ========================================================
// MERGED Token Manager (was in token_manager.dart)
// ========================================================

class TokenManager {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    final expiry = DateTime.now()
        .add(Constants.sessionDuration)
        .toIso8601String();

    await _prefs.setString(Constants.storageTokenKey, token);
    await _prefs.setString(Constants.storageExpiryKey, expiry);
  }

  static String? getToken() {
    return _prefs.getString(Constants.storageTokenKey);
  }

  static DateTime? getExpiry() {
    final s = _prefs.getString(Constants.storageExpiryKey);
    if (s == null) return null;

    return DateTime.parse(s);
  }

  static bool isExpired() {
    final exp = getExpiry();
    if (exp == null) return true; 
    return DateTime.now().isAfter(exp);
  }

  static Future<void> deleteToken() async {
    await _prefs.remove(Constants.storageTokenKey);
    await _prefs.remove(Constants.storageExpiryKey);
  }
}
*/