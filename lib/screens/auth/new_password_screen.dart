import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String? otp;
  
  const NewPasswordScreen({
    super.key, 
    required this.email,
    this.otp,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  String? errorMessage;
  String? passwordError;
  String? confirmError;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    setState(() {
      errorMessage = null;
      passwordError = null;
      confirmError = null;
    });

    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    // Validation
    if (password.isEmpty) {
      setState(() => passwordError = "Password required");
      return;
    }
    if (password.length < 6) {
      setState(() => passwordError = "Password must be at least 6 characters");
      return;
    }
    if (confirm.isEmpty) {
      setState(() => confirmError = "Please confirm password");
      return;
    }
    if (password != confirm) {
      setState(() => confirmError = "Passwords do not match");
      return;
    }

    setState(() => loading = true);

    try {
      // ✅ Your backend expects email and newPassword
      final res = await ApiClient.post("/auth/reset-password", {
        "email": widget.email,
        "newPassword": password,
      });

      print("✅ Reset Password Response: $res"); // Debug log

      // ✅ Backend returns just a message, no success field
      if (res["message"] == "Password reset successful" || res["success"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Password reset successfully! Please login."),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to login and clear all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          errorMessage = res["message"] ?? "Failed to reset password";
        });
      }
    } catch (e) {
      print("❌ Reset password error: $e");
      
      String errorString = e.toString().toLowerCase();
      
      if (errorString.contains('400')) {
        setState(() => errorMessage = "Invalid request. Please try again.");
      } else if (errorString.contains('404')) {
        setState(() => errorMessage = "User not found");
      } else if (errorString.contains('socket') || 
                 errorString.contains('network') || 
                 errorString.contains('connection')) {
        setState(() => errorMessage = "Connection error. Check your internet.");
      } else {
        setState(() => errorMessage = "Failed to reset password. Please try again.");
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const GradientText(
          text: "New Password",
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: CustomCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Create New Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your new password must be different from previous passwords",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 32),

                // New Password Field
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: TextStyle(color: AppTheme.textPrimary(context)),
                  decoration: InputDecoration(
                    labelText: "New Password",
                    labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary(context),
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                    errorText: passwordError,
                    errorStyle: const TextStyle(color: AppTheme.error),
                    filled: true,
                    fillColor: AppTheme.background(context),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null ? AppTheme.error : AppTheme.borderColor(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null ? AppTheme.error : AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.error, width: 2),
                    ),
                  ),
                  onChanged: (_) {
                    if (passwordError != null) setState(() => passwordError = null);
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password Field
                TextField(
                  controller: confirmController,
                  obscureText: obscureConfirm,
                  style: TextStyle(color: AppTheme.textPrimary(context)),
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary(context),
                      ),
                      onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                    ),
                    errorText: confirmError,
                    errorStyle: const TextStyle(color: AppTheme.error),
                    filled: true,
                    fillColor: AppTheme.background(context),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: confirmError != null ? AppTheme.error : AppTheme.borderColor(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: confirmError != null ? AppTheme.error : AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.error, width: 2),
                    ),
                  ),
                  onChanged: (_) {
                    if (confirmError != null) setState(() => confirmError = null);
                  },
                  onSubmitted: (_) {
                    if (!loading) resetPassword();
                  },
                ),

                // General Error Message
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: AppTheme.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Reset Password Button
                ElevatedButton(
                  onPressed: loading ? null : resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Reset Password",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}