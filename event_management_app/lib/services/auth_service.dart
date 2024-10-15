// auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    bool isAdmin = prefs.getBool('isAdmin') ?? false; // Retrieve admin status
    if (token != null) {
      return {'token': token, 'isAdmin': isAdmin};
    }
    return null; // Return null if no token
  }
}
