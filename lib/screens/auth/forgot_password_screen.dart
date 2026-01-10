import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool loading = false;
  String? errorMessage;
  String? emailError;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> sendOtp() async {
    setState(() {
      errorMessage = null;
      emailError = null;
    });

    final email = emailController.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() => emailError = "Email required");
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => emailError = "Invalid email");
      return;
    }

    setState(() => loading = true);

    try {
      await ApiClient.forgotPassword(email);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(email: email),
        ),
      );
    } catch (e) {
      print("❌ Forgot password error: $e");
      String errorString = e.toString().toLowerCase();
      
      if (errorString.contains('socket') || 
          errorString.contains('network') || 
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        setState(() => errorMessage = "Connection error. Check your internet.");
      } else if (errorString.contains('user not found') || 
                 errorString.contains('no user')) {
        setState(() => errorMessage = "User not found");
      } else {
        setState(() => errorMessage = "Invalid email or user not found");
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
          text: "Forgot Password",
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
                  "Reset Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your email to receive OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppTheme.textPrimary(context)),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: AppTheme.textSecondary(context)),
                    prefixIcon: Icon(Icons.email, color: AppTheme.textSecondary(context)),
                    errorText: emailError,
                    errorStyle: const TextStyle(color: AppTheme.error),
                    filled: true,
                    fillColor: AppTheme.background(context),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: emailError != null ? AppTheme.error : AppTheme.borderColor(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: emailError != null ? AppTheme.error : AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.error),
                    ),
                  ),
                  onChanged: (_) {
                    if (emailError != null) {
                      setState(() => emailError = null);
                    }
                  },
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
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
                            style: const TextStyle(
                              color: AppTheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: loading ? null : sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
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
                          "Send OTP",
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
        ),
      ),
    );
  }
}
