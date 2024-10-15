// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8090/api/collections';

  // Function to sign up a new user
  static Future<dynamic> signUp(String email, String password, String passwordConfirm) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'isAdmin': false,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body)['message'] ?? 'Error during signup';
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

// api_service.dart (within the login method)
static Future<dynamic> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/auth-with-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identity': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var userData = json.decode(response.body);
      // Store token and admin status in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userData['token']);
      await prefs.setBool('isAdmin', userData['record']['isAdmin']); // Save isAdmin status
      return userData;
    } else {
      return json.decode(response.body)['message'] ?? 'Login error';
    }
  } catch (e) {
    return 'Connection error: $e';
  }
}


  // Function to fetch events
  static Future<List<Event>> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/records'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] is List) {
          return (data['items'] as List).map((event) => Event(
            id: event['id'],
            title: event['title'],
            description: event['description'],
            date: DateTime.parse(event['date']),
            createdBy: event['createdBy'],
          )).toList();
        } else {
          throw Exception('Expected a list but got: $data');
        }
      } else {
        throw Exception('Failed to load events: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load events');
    }
  }

  // Function to add an event
 static Future<dynamic> addEvent(String title, String description, DateTime date, String token) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/events/records'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ใช้ token ที่ส่งเข้ามา
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'createdBy': 'ui5ldqnmu1qt3es', // แทนที่ด้วย ID ของผู้ดูแลระบบ
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      // แสดงข้อผิดพลาดที่ตอบกลับจาก API
      print('Error adding event: ${response.body}');
      return json.decode(response.body); // แสดงข้อผิดพลาด
    }
  } catch (e) {
    print('Error during adding event: $e');
    return null; // ส่งคืน null ถ้ามีข้อผิดพลาด
  }
}
  static Future<void> logout() async {
    // ถ้ามีการจัดการ token หรือ session คุณสามารถทำการลบได้ที่นี่
    // ในกรณีนี้ไม่ต้องทำอะไรกับ API
  }
}


