import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/custom_card.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  const NewPasswordScreen({super.key, required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> resetPassword() async {
    if (passwordController.text != confirmController.text) {
      setState(() => error = "Passwords do not match");
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await ApiClient.resetPassword(
        email: widget.email,
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      setState(() => error = "Failed to reset password");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("New Password")),
      body: Center(
        child: CustomCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Confirm Password"),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : resetPassword,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
