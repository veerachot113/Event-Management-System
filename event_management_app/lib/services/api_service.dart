// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8090/api/collections';

  // ฟังก์ชันล็อกอิน
// services/api_service.dart
static Future<dynamic> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/auth-with-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identity': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var userData = json.decode(response.body);
      // เก็บ token, admin status และ userId ใน SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userData['token']);
      await prefs.setBool('isAdmin', userData['record']['isAdmin']);
      await prefs.setString('userId', userData['record']['id']); // บันทึก userId

      print("Token Saved: ${userData['token']}");
      print("User ID Saved: ${userData['record']['id']}");
      return userData;
    } else {
      return json.decode(response.body)['message'] ?? 'Login error';
    }
  } catch (e) {
    return 'Connection error: $e';
  }
}


  // ฟังก์ชันสมัครสมาชิก
  static Future<dynamic> signUp(String email, String password, String passwordConfirm) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          'isAdmin': false, // ตั้งค่าเริ่มต้นว่าเป็นผู้ใช้ทั่วไป
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        // ตรวจสอบว่ามีข้อความแสดงข้อผิดพลาดหรือไม่
        return json.decode(response.body)['message'] ?? 'Error during signup';
      }
    } catch (e) {
      return 'Connection error: $e';
    }
  }

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

      print('Response status code: ${response.statusCode}');

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

  // ฟังก์ชันดึงข้อมูลกิจกรรม
// services/api_service.dart
// services/api_service.dart
// services/api_service.dart
static Future<List<Event>> getEvents(String userId) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/events/records'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] is List) {
        return (data['items'] as List).map((event) {
          List<dynamic> participants = event['participants'] ?? [];
          bool isJoined = participants.contains(userId);

          return Event(
            id: event['id'],
            title: event['title'],
            description: event['description'],
            date: DateTime.parse(event['date']),
            createdBy: event['createdBy'],
            imageUrl: event['image'] != null
                ? 'http://127.0.0.1:8090/api/files/events/${event['id']}/${event['image']}'
                : null,
            participantCount: participants.length,
            isJoined: isJoined,
            participants: participants.cast<String>(), // เก็บ ID หรือชื่อผู้เข้าร่วม
          );
        }).toList();
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




  // ฟังก์ชันเข้าร่วมกิจกรรม
// services/api_service.dart
static Future<String?> joinEvent(String eventId, String userId, String token) async {
  try {
    final response = await http.patch(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "participants": [
          userId
        ]
      }),
    );

    if (response.statusCode == 200) {
      return null; // สำเร็จ
    } else {
      // คืนค่าข้อความแสดงข้อผิดพลาดจาก API
      String errorMessage = json.decode(response.body)['message'] ?? 'Error joining event';
      print('Error joining event: $errorMessage');
      return errorMessage;
    }
  } catch (e) {
    print('Error during joining event: $e');
    return 'Connection error: $e';
  }
}


  // ฟังก์ชันยกเลิกการเข้าร่วมกิจกรรม
// services/api_service.dart
static Future<String?> cancelJoinEvent(String eventId, String userId, String token) async {
  try {
    // ดึงข้อมูลกิจกรรมก่อนเพื่อลบ userId ออกจาก participants
    final response = await http.get(Uri.parse('$baseUrl/events/records/$eventId'), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      return 'Failed to fetch event data';
    }

    final eventData = json.decode(response.body);
    List<dynamic> participants = eventData['participants'] ?? [];

    // ลบ userId ออกจาก participants
    participants.remove(userId);

    // อัปเดตข้อมูลกิจกรรมด้วยรายการ participants ใหม่
    final updateResponse = await http.patch(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "participants": participants,
      }),
    );

    if (updateResponse.statusCode == 200) {
      return null; // สำเร็จ
    } else {
      String errorMessage = json.decode(updateResponse.body)['message'] ?? 'Error canceling join event';
      print('Error canceling join event: $errorMessage');
      return errorMessage;
    }
  } catch (e) {
    print('Error during canceling join event: $e');
    return 'Connection error: $e';
  }
}


  // ฟังก์ชันลบกิจกรรม
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

  // ฟังก์ชันออกจากระบบ
  static Future<void> logout() async {
    // ถ้ามีการจัดการ token หรือ session คุณสามารถทำการลบได้ที่นี่
    // ในกรณีนี้ไม่ต้องทำอะไรกับ API
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isAdmin');
    await prefs.remove('userId');
  }
}
