import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../api_client.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/custom_card.dart';
import 'new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool loading = false;
  String? errorMessage;

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return otpControllers.map((c) => c.text).join();
  }

  Future<void> verifyOtp() async {
    final otp = getOtp();
    
    if (otp.length != 6) {
      setState(() => errorMessage = "Please enter complete OTP");
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // ✅ Using your existing ApiClient.checkOtp method
      await ApiClient.checkOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;

      // Navigate to New Password Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NewPasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      print("❌ OTP verification error: $e");
      setState(() {
        errorMessage = "Invalid or expired OTP";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> resendOtp() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // Clear existing OTP inputs
      for (var controller in otpControllers) {
        controller.clear();
      }
      
      await ApiClient.forgotPassword(widget.email);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("OTP sent successfully!"),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print("❌ Resend OTP error: $e");
      setState(() {
        errorMessage = "Failed to resend OTP";
      });
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
          text: "Verify OTP",
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
              children: [
                Icon(
                  Icons.mark_email_read,
                  size: 64,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Enter Verification Code",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We sent a code to",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => _buildOtpBox(index),
                  ),
                ),

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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
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
                  onPressed: loading ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
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
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: loading ? null : resendOtp,
                  child: const Text(
                    "Didn't receive code? Resend",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: AppTheme.background(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: otpControllers[index].text.isNotEmpty
              ? AppTheme.primary
              : AppTheme.borderColor(context),
          width: otpControllers[index].text.isNotEmpty ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary(context),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        onSubmitted: (_) {
          if (index == 5 && getOtp().length == 6) {
            verifyOtp();
          }
        },
      ),
    );
  }
}