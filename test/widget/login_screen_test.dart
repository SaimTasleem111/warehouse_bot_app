import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehousebot_app/screens/auth/login_screen.dart';

void main() {
  group('TC-001: User Authentication (Login)', () {
    testWidgets('Login screen loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Login screen uses TextField, not TextFormField
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('WarehouseBot'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and Password
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Should show error when email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Tap Sign In without entering credentials
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email required'), findsOneWidget);
    });

    testWidgets('Should show error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextField).first, 'invalidemail');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('Should show error when password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Enter valid email but no password
      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password required'), findsOneWidget);
    });

    testWidgets('Should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      final passwordField = find.byType(TextField).last;
      
      // Initially password should be obscured
      TextField textField = tester.widget(passwordField);
      expect(textField.obscureText, true);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Password should now be visible
      textField = tester.widget(passwordField);
      expect(textField.obscureText, false);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // Password should be obscured again
      textField = tester.widget(passwordField);
      expect(textField.obscureText, true);
    });

    testWidgets('User can enter credentials', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Enter email
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.pumpAndSettle();

      // Verify text is entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Should navigate to Forgot Password screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // Tap Forgot Password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Should navigate to forgot password screen
      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('Sign In button should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      final button = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(button, findsOneWidget);

      // Verify button is enabled initially
      final ElevatedButton elevatedButton = tester.widget(button);
      expect(elevatedButton.onPressed, isNotNull);
    });
  });
}