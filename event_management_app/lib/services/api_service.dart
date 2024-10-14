// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // Function to login a user
  static Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/auth-with-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identity': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
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

static Future<dynamic> addEvent(String title, String description, DateTime date, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/records'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Use token passed from AddEventPage
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'date': date.toIso8601String(),
          'createdBy': 'ui5ldqnmu1qt3es', // Replace with actual admin ID
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('Error adding event: ${response.body}');
        return null; // Return null if there was an error
      }
    } catch (e) {
      print('Error during adding event: $e');
      return null;
    }
}


}
