// services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    bool isAdmin = prefs.getBool('isAdmin') ?? false;
    String? userId = prefs.getString('userId');

    print("Token from AuthService: $token");
    print("User ID from AuthService: $userId");

    if (token != null && userId != null) {
      return {'token': token, 'isAdmin': isAdmin, 'userId': userId};
    }
    return null;
  }
}
