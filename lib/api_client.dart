import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class ApiClient {
  static const String baseUrl = "https://warehouse-bot-backend.vercel.app";

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        print("API Error ${res.statusCode}: ${res.body}");
        throw Exception("Request failed: ${res.statusCode}");
      }
    } catch (e) {
      print("API POST Error: $e");
      rethrow;
    }
  }

  static Future<dynamic> get(String endpoint, String token) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        print("API Error ${res.statusCode}: ${res.body}");
        throw Exception("Request failed: ${res.statusCode}");
      }
    } catch (e) {
      print("API GET Error: $e");
      rethrow;
    }
  }

  static Future<dynamic> login(Map<String, dynamic> data) async {
    return post("/auth/login", data);
  }

  static Future<dynamic> register(Map<String, dynamic> data) async {
    return post("/auth/register", data);
  }

  // Orders / Products / Dashboard
  static Future<dynamic> fetchOrders({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    return get("/api/orders?page=$page&limit=$limit", token);
  }

  static Future<dynamic> fetchProducts({
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    return get("/api/products?page=$page&limit=$limit", token);
  }

  static Future<dynamic> fetchDashboardDetails({required String token}) async {
    return get("/api/dashboard-info", token);
  }

  static Future<dynamic> fetchRobots({required String token}) async {
    return get("/api/fetch-robots?limit=2", token);
  }

  static Future<dynamic> getRobotLogs({required String token}) async {
    return get("/api/get-robot-logs?limit=10", token);
  }

  static Future<dynamic> getJobs({required String token}) async {
    return get("/api/get-jobs?limit=10", token);
  }

  // AUTH – PASSWORD RESET FLOW
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await post(
      "/auth/forgot-password",
      {"email": email},
    );

    return response;
  }

  static Future<dynamic> checkOtp({
    required String email,
    required String otp,
  }) {
    return post("/auth/check-otp", {
      "email": email,
      "otp": otp,
    });
  }

  static Future<dynamic> resetPassword({
    required String email,
    required String password,
  }) {
    return post("/auth/reset-password", {
      "email": email.trim().toLowerCase(),
      "newPassword": password.trim(),
    });
  }

  // NOTIFICATIONS
  static Future<dynamic> fetchNotifications({
    required String token,
    required String userId,
  }) async {
    return get("/api/notification/$userId", token);
  }

  // FIREBASE - Send FCM token to backend (optional, if you want to track devices)
  static Future<void> sendFcmToken({
    required String token,
    required String userId,
  }) async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await post("/api/update-fcm-token", {
          "userId": userId,
          "fcmToken": fcmToken,
        });
        print("✅ FCM token sent to backend");
      }
    } catch (e) {
      print("❌ Error sending FCM token: $e");
    }
  }
}