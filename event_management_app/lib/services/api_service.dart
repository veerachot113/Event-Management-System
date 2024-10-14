import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8090/api/collections';

  // ฟังก์ชันลงทะเบียน
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
        return json.decode(response.body)['message'] ?? 'เกิดข้อผิดพลาดในการสมัครสมาชิก';
      }
    } catch (e) {
      return 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์';
    }
  }

  // ฟังก์ชันเข้าสู่ระบบ
  static Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/auth-with-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identity': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        return errorBody['message'] ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
      }
    } catch (e) {
      return 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์';
    }
  }

  // ฟังก์ชันดึงรายการกิจกรรม
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
          throw Exception('Expected a list of events but got a map: $data');
        }
      } else {
        throw Exception('Failed to load events: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load events');
    }
  }

  // ฟังก์ชันเพิ่มกิจกรรม
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
          'createdBy': 'ui5ldqnmu1qt3es', // ควรใช้ ID ของผู้ดูแลระบบจริง
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('Error adding event: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during adding event: $e');
      return null;
    }
  }
}
