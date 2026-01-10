import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
void main() {}

class MockApiClient {
  static Future<Map<String, dynamic>> mockLoginSuccess() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      "success": true,
      "token": "mock_token_12345",
      "userId": "user_123",
      "name": "Test User",
      "user": {
        "_id": "user_123",
        "name": "Test User",
        "email": "test@example.com",
      }
    };
  }

  static Future<void> mockLoginFailure() async {
    await Future.delayed(const Duration(milliseconds: 100));
    throw Exception("Wrong email or password");
  }

  static Future<Map<String, dynamic>> mockForgotPasswordSuccess() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {"success": true, "message": "OTP sent successfully"};
  }

  static Future<Map<String, dynamic>> mockCheckOtpSuccess() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {"success": true, "message": "OTP verified successfully"};
  }

  static Future<Map<String, dynamic>> mockResetPasswordSuccess() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {"success": true, "message": "Password reset successful"};
  }

  static Future<Map<String, dynamic>> mockDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      "data": [
        {
          "robotId": "robot_1",
          "name": "Robot Alpha",
          "model": "WH-500",
          "status": "busy",
          "batteryLevel": 85,
          "currentJob": "Job #123"
        },
        {
          "robotId": "robot_2",
          "name": "Robot Beta",
          "model": "WH-500",
          "status": "idle",
          "batteryLevel": 65,
          "currentJob": "None"
        }
      ]
    };
  }

  static Future<Map<String, dynamic>> mockOrdersData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      "orders": [
        {"orderId": "ord_1", "status": "pending"},
        {"orderId": "ord_2", "status": "completed"},
        {"orderId": "ord_3", "status": "in transit"},
        {"orderId": "ord_4", "status": "pending"},
      ],
      "totalOrders": 4
    };
  }
}