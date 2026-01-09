import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../helperFunction/tokenStorage.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool badCreds = false;

  Future<void> loginUser() async {
    setState(() {
      loading = true;
      badCreds = false;
    });

    try {
      final res = await ApiClient.post("/auth/login", {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      });

      if (res["success"] == true && res["token"] != null) {
        // Save all user data including userId
        await TokenStorage.saveUserData(
          token: res["token"],
          userId: res["userId"] ?? res["user"]?["_id"] ?? "", // Handle different response formats
          email: emailController.text.trim(),
          name: res["name"] ?? res["user"]?["name"] ?? "", // If backend returns name
        );

        // Optional: Send FCM token to backend for device-specific notifications
        try {
          final userId = res["userId"] ?? res["user"]?["_id"];
          if (userId != null && userId.isNotEmpty) {
            await ApiClient.sendFcmToken(
              token: res["token"],
              userId: userId,
            );
          }
        } catch (e) {
          print("⚠️ FCM token upload failed: $e");
          // Don't block login if this fails
        }

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNav(currentIndex: 0),
          ),
          (_) => false,
        );
      } else {
        setState(() => badCreds = true);
      }
    } catch (e) {
      print("❌ Login error: $e");
      setState(() => badCreds = true);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GradientText(
                text: "WarehouseBot",
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              const Text(
                "Intelligent Warehouse Management",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              CustomCard(
                padding: const EdgeInsets.all(28),
                backgroundColor: AppTheme.surface,
                borderColor: AppTheme.borderLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// EMAIL
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: _inputDecoration(
                        label: "Email",
                        icon: Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: _inputDecoration(
                        label: "Password",
                        icon: Icons.lock_outline,
                      ),
                      onSubmitted: (_) => loading ? null : loginUser(),
                    ),

                    const SizedBox(height: 12),

                    /// FORGOT PASSWORD (CLICKABLE)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    if (badCreds) ...[
                      const SizedBox(height: 12),
                      _errorBox(),
                    ],

                    const SizedBox(height: 24),

                    /// LOGIN BUTTON
                    ElevatedButton(
                      onPressed: loading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        disabledBackgroundColor:
                            AppTheme.primary.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// INPUT DECORATION
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.background,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppTheme.primary,
          width: 2,
        ),
      ),
    );
  }

  /// ERROR BOX
  Widget _errorBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: const [
          Icon(Icons.error_outline, color: AppTheme.error, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Invalid credentials. Please try again.",
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}