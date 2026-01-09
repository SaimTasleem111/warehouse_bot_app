import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_card.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final otpController = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> verifyOtp() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await ApiClient.checkOtp(
        email: widget.email,
        otp: otpController.text.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      setState(() {
        error = "Invalid or expired OTP";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Center(
        child: CustomCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : verifyOtp,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Verify OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
