// screens/events.dart
import 'package:event_management_app/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'add_event.dart';
import 'edit_event.dart';
import '../models/event.dart';
import 'login.dart';
// เพิ่ม import สำหรับ EventDetailPage

class EventsPage extends StatefulWidget {
  final String token;
  final bool isAdmin;

  EventsPage({required this.token, required this.isAdmin});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

// screens/events.dart
Future<void> fetchEvents() async {
  setState(() {
    isLoading = true;
  });

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    print("Token Loaded: $token");
    print("User ID Loaded: $userId");

    if (token == null || userId == null) {
      throw Exception('ไม่พบ Token หรือ User ID');
    }

    final fetchedEvents = await ApiService.getEvents(userId);
    setState(() {
      events = fetchedEvents;
      isLoading = false;
    });
  } catch (error) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching events: $error')));
  }
}




  void onEventAdded(Event newEvent) {
    setState(() {
      events.add(newEvent);
    });
  }

  void onEventUpdated(Event updatedEvent) {
    setState(() {
      int index = events.indexWhere((event) => event.id == updatedEvent.id);
      if (index != -1) {
        events[index] = updatedEvent;
      }
    });
  }

  void deleteEvent(String eventId) async {
    bool success = await ApiService.deleteEvent(eventId, widget.token);
    if (success) {
      setState(() {
        events.removeWhere((event) => event.id == eventId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ลบกิจกรรมสำเร็จ')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถลบกิจกรรม')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการกิจกรรม'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchEvents,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // ลบข้อมูลการเข้าสู่ระบบและกลับไปหน้าเข้าสู่ระบบ
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events[index],
                  isAdmin: widget.isAdmin,
                  token: widget.token,
                  onEventUpdated: onEventUpdated,
                  onDelete: deleteEvent,
                );
              },
            ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(
                      token: widget.token,
                      onEventAdded: onEventAdded,
                    ),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
