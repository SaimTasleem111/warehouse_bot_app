import 'package:flutter/material.dart';
import '../helperFunction/tokenStorage.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/app_theme.dart';

class LogoutHelper {
  /// Shows a confirmation dialog and logs out the user if confirmed
  static Future<void> showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Logout",
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(
            color: AppTheme.textSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: AppTheme.textSecondary(context),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await logout(context);
    }
  }

  /// Performs the logout operation
  static Future<void> logout(BuildContext context) async {
    // Clear all user data from SharedPreferences
    await TokenStorage.clearAll();
    
    if (!context.mounted) return;

    // Navigate to login screen and clear navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (_) => false,
    );
  }

  /// Quick logout without confirmation dialog
  static Future<void> logoutWithoutConfirmation(BuildContext context) async {
    await logout(context);
  }
}