class MockTokenStorage {
  static String? _token;
  static String? _userId;
  static String? _email;
  static String? _name;

  static Future<void> saveUserData({
    required String token,
    required String userId,
    required String email,
    required String name,
  }) async {
    _token = token;
    _userId = userId;
    _email = email;
    _name = name;
  }

  static Future<String?> getToken() async => _token;
  static Future<String?> getUserId() async => _userId;
  static Future<String?> getEmail() async => _email;
  static Future<String?> getName() async => _name;

  static void reset() {
    _token = null;
    _userId = null;
    _email = null;
    _name = null;
  }
}
