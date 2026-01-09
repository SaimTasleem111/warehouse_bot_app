import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../widgets/app_theme.dart';
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
  String? error;

  Future<void> sendOtp() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await ApiClient.forgotPassword(emailController.text.trim());

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: emailController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        error = "Invalid email or user not found";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Center(
        child: CustomCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Enter Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : sendOtp,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Send OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
