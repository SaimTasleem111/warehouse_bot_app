import 'package:flutter_test/flutter_test.dart';

import 'widget/login_screen_test.dart' as login_tests;
import 'widget/forgot_password_flow_test.dart' as password_reset_tests;
import 'widget/dashboard_screen_test.dart' as dashboard_tests;

void main() {
  group('WarehouseBot Test Suite', () {
    group('TC-001: User Authentication (Login)', () {
      login_tests.main();
    });

    group('TC-002: Password Reset Functionality', () {
      password_reset_tests.main();
    });

    group('TC-005: Dashboard Displays Real-Time Updates', () {
      dashboard_tests.main();
    });
  });
}
