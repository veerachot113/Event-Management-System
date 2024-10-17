// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8090/api/collections';

  // ฟังก์ชันล็อกอิน
static Future<dynamic> login(String identity, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/auth-with-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identity': identity, 'password': password}), // เปลี่ยน identity เป็นทั้ง email หรือ username ได้
    );

    if (response.statusCode == 200) {
      var userData = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userData['token']);
      await prefs.setBool('isAdmin', userData['record']['isAdmin']);
      await prefs.setString('userId', userData['record']['id']); 
      return userData;
    } else {
      return json.decode(response.body)['message'] ?? 'Login error';
    }
  } catch (e) {
    return 'Connection error: $e';
  }
}


  // ฟังก์ชันสมัครสมาชิก
static Future<dynamic> signUp(String username, String email, String password, String passwordConfirm) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username, // เพิ่มการส่ง Username
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


  // ฟังก์ชันเพิ่มกิจกรรม
  static Future<dynamic> addEvent(
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,
    String location, // เพิ่มพารามิเตอร์ location
    String token,
    Uint8List? imageData,
    String? imageName
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/events/records'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['startDate'] = startDate.toIso8601String();
      request.fields['endDate'] = endDate.toIso8601String();
      request.fields['location'] = location; // ส่งข้อมูล location
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
    DateTime startDate,
    DateTime endDate,
    String location, // เพิ่มพารามิเตอร์ location
    String token,
    Uint8List? imageData, 
    String? imageName
  ) async {
    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/events/records/$eventId'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['startDate'] = startDate.toIso8601String();
      request.fields['endDate'] = endDate.toIso8601String();
      request.fields['location'] = location; // ส่งข้อมูล location

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
              startDate: DateTime.parse(event['startDate']),
              endDate: DateTime.parse(event['endDate']),
              createdBy: event['createdBy'],
              imageUrl: event['image'] != null
                  ? 'http://127.0.0.1:8090/api/files/events/${event['id']}/${event['image']}'
                  : null,
              participantCount: participants.length,
              isJoined: isJoined,
              participants: participants.cast<String>(),
              location: event['location'], // เพิ่มฟิลด์ location
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
 // ฟังก์ชันเข้าร่วมกิจกรรม
static Future<String?> joinEvent(String eventId, String userId, String token) async {
  try {
    // ดึงข้อมูลกิจกรรมก่อนเพื่อตรวจสอบว่ามีผู้เข้าร่วมอยู่แล้วหรือไม่
    final response = await http.get(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      return 'Failed to fetch event data';
    }

    final eventData = json.decode(response.body);
    List<dynamic> participants = eventData['participants'] ?? [];

    // ตรวจสอบว่าผู้ใช้ยังไม่ได้เข้าร่วม
    if (!participants.contains(userId)) {
      participants.add(userId);
    }

    // อัปเดตรายการผู้เข้าร่วมใหม่
    final updateResponse = await http.patch(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"participants": participants}),
    );

    if (updateResponse.statusCode == 200) {
      return null; // สำเร็จ
    } else {
      String errorMessage = json.decode(updateResponse.body)['message'] ?? 'Error joining event';
      return errorMessage;
    }
  } catch (e) {
    return 'Connection error: $e';
  }
}

// ฟังก์ชันยกเลิกการเข้าร่วมกิจกรรม
static Future<String?> cancelJoinEvent(String eventId, String userId, String token) async {
  try {
    // ดึงข้อมูลกิจกรรมก่อนเพื่อลบ userId ออกจาก participants
    final response = await http.get(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      return 'Failed to fetch event data';
    }

    final eventData = json.decode(response.body);
    List<dynamic> participants = eventData['participants'] ?? [];

    // ลบ userId ออกจาก participants
    participants.remove(userId);

    // อัปเดตรายการผู้เข้าร่วมใหม่
    final updateResponse = await http.patch(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"participants": participants}),
    );

    if (updateResponse.statusCode == 200) {
      return null; // สำเร็จ
    } else {
      String errorMessage = json.decode(updateResponse.body)['message'] ?? 'Error canceling join event';
      return errorMessage;
    }
  } catch (e) {
    return 'Connection error: $e';
  }
}

static Future<String?> removeParticipant(String eventId, String userId, String token) async {
  try {
    // ดึงข้อมูลกิจกรรมก่อนเพื่อลบ userId ออกจาก participants
    final response = await http.get(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      return 'Failed to fetch event data';
    }

    final eventData = json.decode(response.body);
    List<dynamic> participants = eventData['participants'] ?? [];

    // ลบ userId ออกจาก participants
    participants.remove(userId);

    // อัปเดตรายการผู้เข้าร่วมใหม่
    final updateResponse = await http.patch(
      Uri.parse('$baseUrl/events/records/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"participants": participants}),
    );

    if (updateResponse.statusCode == 200) {
      return null; // สำเร็จ
    } else {
      String errorMessage = json.decode(updateResponse.body)['message'] ?? 'Error removing participant';
      return errorMessage;
    }
  } catch (e) {
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
// services/api_service.dart
  // ฟังก์ชันดึงข้อมูลผู้ใช้จาก userId
  static Future<String?> getUsernameFromUserId(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/records/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['username'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }


  // ฟังก์ชันออกจากระบบ
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isAdmin');
    await prefs.remove('userId');
  }
}
