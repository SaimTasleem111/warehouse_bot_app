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
  bool obscurePassword = true;
  String? errorMessage;
  String? emailError;
  String? passwordError;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> loginUser() async {
    // Clear previous errors
    setState(() {
      errorMessage = null;
      emailError = null;
      passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() => emailError = "Email required");
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => emailError = "Invalid email");
      return;
    }

    // Validate password
    if (password.isEmpty) {
      setState(() => passwordError = "Password required");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiClient.post("/auth/login", {
        "email": email,
        "password": password,
      });

      print('🔍 API Response: $res');

      if (res["success"] == true && res["token"] != null) {
        // Extract userId from multiple possible locations
        String userId = "";
        
        // Try different possible locations for userId
        if (res["userId"] != null && res["userId"].toString().isNotEmpty) {
          userId = res["userId"].toString();
        } else if (res["user"] != null && res["user"]["_id"] != null) {
          userId = res["user"]["_id"].toString();
        } else if (res["user"] != null && res["user"]["id"] != null) {
          userId = res["user"]["id"].toString();
        } else if (res["_id"] != null) {
          userId = res["_id"].toString();
        } else if (res["id"] != null) {
          userId = res["id"].toString();
        }

        print('🔐 LOGIN SUCCESS');
        print('📦 Extracted Data:');
        print('  Token: ${res["token"].toString().substring(0, 20)}...');
        print('  UserId: $userId');
        print('  Email: $email');
        print('  Name: ${res["name"] ?? res["user"]?["name"] ?? ""}');

        if (userId.isEmpty) {
          print('⚠️ WARNING: UserId is empty! Check API response structure.');
          print('Full response: $res');
        }

        await TokenStorage.saveUserData(
          token: res["token"],
          userId: userId,
          email: email,
          name: res["name"] ?? res["user"]?["name"] ?? "",
        );

        // VERIFICATION: Check if data was actually saved
        final savedToken = await TokenStorage.getToken();
        final savedUserId = await TokenStorage.getUserId();
        final savedEmail = await TokenStorage.getUserEmail();
        final savedName = await TokenStorage.getUserName();
        
        print('✅ VERIFICATION AFTER SAVE:');
        print('  Token: ${savedToken != null ? "EXISTS (${savedToken.length} chars)" : "NULL"}');
        print('  UserId: $savedUserId');
        print('  Email: $savedEmail');
        print('  Name: $savedName');

        try {
          if (userId.isNotEmpty) {
            await ApiClient.sendFcmToken(
              token: res["token"],
              userId: userId,
            );
          }
        } catch (e) {
          print("⚠️ FCM token upload failed: $e");
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
        setState(() => errorMessage = "Wrong email or password");
      }
    } catch (e) {
      print("❌ Login error: $e");
      String errorString = e.toString().toLowerCase();
      
      if (errorString.contains('socket') || 
          errorString.contains('network') || 
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        setState(() => errorMessage = "Connection error. Check your internet.");
      } else if (errorString.contains('user not found') || 
                 errorString.contains('no user')) {
        setState(() => errorMessage = "User not found");
      } else if (errorString.contains('401') || 
                 errorString.contains('unauthorized') ||
                 errorString.contains('invalid credentials')) {
        setState(() => errorMessage = "Wrong email or password");
      } else {
        setState(() => errorMessage = "Internal server error");
      }
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
      backgroundColor: AppTheme.background(context),
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
              Text(
                "Intelligent Warehouse Management",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary(context),
                ),
              ),
              const SizedBox(height: 48),

              CustomCard(
                padding: const EdgeInsets.all(28),
                backgroundColor: AppTheme.surface(context),
                borderColor: AppTheme.borderLight(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppTheme.textPrimary(context)),
                      decoration: _inputDecoration(
                        context: context,
                        label: "Email",
                        icon: Icons.email_outlined,
                        errorText: emailError,
                      ),
                      onChanged: (_) {
                        if (emailError != null) {
                          setState(() => emailError = null);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: TextStyle(color: AppTheme.textPrimary(context)),
                      decoration: _inputDecoration(
                        context: context,
                        label: "Password",
                        icon: Icons.lock_outline,
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary(context),
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (_) {
                        if (passwordError != null) {
                          setState(() => passwordError = null);
                        }
                      },
                      onSubmitted: (_) => loading ? null : loginUser(),
                    ),

                    const SizedBox(height: 12),

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

                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _errorBox(context, errorMessage!),
                    ],

                    const SizedBox(height: 24),

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

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required IconData icon,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary(context)),
      suffixIcon: suffixIcon,
      errorText: errorText,
      errorStyle: const TextStyle(color: AppTheme.error),
      filled: true,
      fillColor: AppTheme.background(context),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? AppTheme.error : AppTheme.borderColor(context),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? AppTheme.error : AppTheme.primary,
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
    );
  }

  Widget _errorBox(BuildContext context, String message) {
    return Container(
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
              message,
              style: const TextStyle(
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