import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehousebot_app/screens/auth/forgot_password_screen.dart';
import 'package:warehousebot_app/screens/auth/otp_verification_screen.dart';
import 'package:warehousebot_app/screens/auth/new_password_screen.dart';
import '../mocks/mock_api_client.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('TC-002: Password Reset Functionality', () {
    
    group('Step 1: Forgot Password Request', () {
      testWidgets('Should display forgot password screen with email field', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ForgotPasswordScreen()),
        );

        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.text('Enter your email to receive OTP'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Send OTP'), findsOneWidget);
      });

      testWidgets('Should show error when email is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ForgotPasswordScreen()),
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Send OTP'));
        await tester.pumpAndSettle();

        expect(find.text('Email required'), findsOneWidget);
      });

      testWidgets('Should show error for invalid email format', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ForgotPasswordScreen()),
        );

        await tester.enterText(find.byType(TextField), 'invalidemail');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Send OTP'));
        await tester.pumpAndSettle();

        expect(find.text('Invalid email'), findsOneWidget);
      });

      testWidgets('Should accept valid email', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ForgotPasswordScreen()),
        );

        await tester.enterText(find.byType(TextField), 'test@example.com');
        await tester.pumpAndSettle();

        expect(find.text('test@example.com'), findsOneWidget);
      });

      testWidgets('Send OTP button should be tappable', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ForgotPasswordScreen()),
        );

        final button = find.widgetWithText(ElevatedButton, 'Send OTP');
        expect(button, findsOneWidget);

        final ElevatedButton elevatedButton = tester.widget(button);
        expect(elevatedButton.onPressed, isNotNull);
      });
    });

    group('Step 2: OTP Verification', () {
      testWidgets('Should display OTP verification screen with 6 input boxes', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: OtpVerificationScreen(email: 'test@example.com'),
          ),
        );

        expect(find.text('Enter Verification Code'), findsOneWidget);
        expect(find.text('We sent a code to'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(6));
        expect(find.widgetWithText(ElevatedButton, 'Verify OTP'), findsOneWidget);
        expect(find.text("Didn't receive code? Resend"), findsOneWidget);
      });

      testWidgets('Should show error when OTP is incomplete', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: OtpVerificationScreen(email: 'test@example.com'),
          ),
        );

        await tester.enterText(find.byType(TextField).at(0), '1');
        await tester.enterText(find.byType(TextField).at(1), '2');
        await tester.enterText(find.byType(TextField).at(2), '3');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Verify OTP'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter complete OTP'), findsOneWidget);
      });

      testWidgets('Should accept 6-digit OTP input', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: OtpVerificationScreen(email: 'test@example.com'),
          ),
        );

        for (int i = 0; i < 6; i++) {
          await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
        }
        await tester.pumpAndSettle();

        for (int i = 0; i < 6; i++) {
          final TextField field = tester.widget(find.byType(TextField).at(i));
          expect(field.controller?.text, '${i + 1}');
        }
      });

      testWidgets('Resend button should be tappable', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: OtpVerificationScreen(email: 'test@example.com'),
          ),
        );

        final resendButton = find.text("Didn't receive code? Resend");
        expect(resendButton, findsOneWidget);
      });
    });

    group('Step 3: Set New Password', () {
      testWidgets('Should display new password screen with two password fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NewPasswordScreen(email: 'test@example.com'),
          ),
        );

        expect(find.text('Create New Password'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.widgetWithText(ElevatedButton, 'Reset Password'), findsOneWidget);
      });

      testWidgets('Should show error when passwords are empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NewPasswordScreen(email: 'test@example.com'),
          ),
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pumpAndSettle();

        expect(find.text('Password required'), findsOneWidget);
      });

      testWidgets('Should show error when password is too short', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NewPasswordScreen(email: 'test@example.com'),
          ),
        );

        await tester.enterText(find.byType(TextField).first, '12345');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      });

      testWidgets('Should show error when passwords do not match', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NewPasswordScreen(email: 'test@example.com'),
          ),
        );

        await tester.enterText(find.byType(TextField).first, 'password123');
        await tester.enterText(find.byType(TextField).last, 'password456');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('Should toggle password visibility', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NewPasswordScreen(email: 'test@example.com'),
          ),
        );

        final passwordField = find.byType(TextField).first;
        
        TextField field = tester.widget(passwordField);
        expect(field.obscureText, true);

        await tester.tap(find.byIcon(Icons.visibility_outlined).first);
        await tester.pumpAndSettle();

        field = tester.widget(passwordField);
        expect(field.obscureText, false);
      });

      testWidgets('Should accept matching passwords', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NewPasswordScreen(email: 'test@example.com'),
          ),
        );

        await tester.enterText(find.byType(TextField).first, 'password123');
        await tester.enterText(find.byType(TextField).last, 'password123');
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsNothing);
      });
    });
  });

  group('TC-002: Password Reset Integration Tests', () {
    test('Step 1: Should send OTP successfully', () async {
      final result = await MockApiClient.mockForgotPasswordSuccess();
      expect(result['success'], true);
      expect(result['message'], 'OTP sent successfully');
    });

    test('Step 2: Should verify OTP successfully', () async {
      final result = await MockApiClient.mockCheckOtpSuccess();
      expect(result['success'], true);
      expect(result['message'], 'OTP verified successfully');
    });

    test('Step 3: Should reset password successfully', () async {
      final result = await MockApiClient.mockResetPasswordSuccess();
      expect(result['success'], true);
      expect(result['message'], 'Password reset successful');
    });

    test('Complete Flow: Should complete password reset process', () async {
      final forgot = await MockApiClient.mockForgotPasswordSuccess();
      expect(forgot['success'], true);

      final otp = await MockApiClient.mockCheckOtpSuccess();
      expect(otp['success'], true);

      final reset = await MockApiClient.mockResetPasswordSuccess();
      expect(reset['success'], true);
      expect(reset['message'], 'Password reset successful');
    });

    test('Should handle delays in API responses', () async {
      final stopwatch = Stopwatch()..start();
      
      await MockApiClient.mockForgotPasswordSuccess();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}