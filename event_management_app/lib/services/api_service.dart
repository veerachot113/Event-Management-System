// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import 'dart:typed_data';


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


  // ฟังก์ชันเพิ่มกิจกรรมพร้อมรูปภาพ
  // ฟังก์ชันเพิ่มกิจกรรม
static Future<dynamic> addEvent(
  String title,
  String description,
  DateTime date,
  String token,
  Uint8List? imageData,
  String? imageName,
) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/events/records'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['date'] = date.toIso8601String();
    request.fields['createdBy'] = 'ui5ldqnmu1qt3es'; // แทนที่ด้วย ID ผู้ใช้จริง

    if (imageData != null && imageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('image', imageData, filename: imageName),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('Response status code: ${response.statusCode}'); // เพิ่มการพิมพ์สถานะการตอบกลับ

    if (response.statusCode >= 200 && response.statusCode < 300) {
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

  // ฟังก์ชันแก้ไขกิจกรรม
  static Future<dynamic> updateEvent(
    String eventId,
    String title,
    String description,
    DateTime date,
    String token,
    Uint8List? imageData, // รับข้อมูลรูปภาพ
    String? imageName,    // รับชื่อไฟล์รูปภาพ
  ) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/events/records/$eventId'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['date'] = date.toIso8601String();

      if (imageData != null && imageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes('image', imageData, filename: imageName),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error updating event: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during updating event: $e');
      return null;
    }
  }


  // ฟังก์ชันดึงกิจกรรม (ปรับปรุงเพื่อรวม imageUrl)
  // ฟังก์ชันดึงข้อมูลกิจกรรม
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
                imageUrl: event['image'] != null
                    ? 'http://127.0.0.1:8090/api/files/events/${event['id']}/${event['image']}'
                    : null,
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

 static Future<bool> deleteEvent(String eventId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/records/$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('Error deleting event: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during deleting event: $e');
      return false;
    }
  }



  static Future<void> logout() async {
    // ถ้ามีการจัดการ token หรือ session คุณสามารถทำการลบได้ที่นี่
    // ในกรณีนี้ไม่ต้องทำอะไรกับ API
  }
}


