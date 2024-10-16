// screens/event_detail.dart
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'participants.dart'; // นำเข้าไฟล์สำหรับหน้าแสดงรายชื่อผู้เข้าร่วม

class EventDetailPage extends StatefulWidget {
  final Event event;
  final Function(Event) onEventUpdated;

  EventDetailPage({required this.event, required this.onEventUpdated});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Event event;
  bool isLoading = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool adminStatus = prefs.getBool('isAdmin') ?? false;
    setState(() {
      isAdmin = adminStatus;
    });
  }

  Future<void> _refreshEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      List<Event> updatedEvents = await ApiService.getEvents(userId);
      Event? updatedEvent = updatedEvents.firstWhere((e) => e.id == event.id, orElse: () => event);
      setState(() {
        event = updatedEvent;
      });
    }
  }

  Future<void> _joinEvent() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId'); // ตรวจสอบว่าบันทึก userId แล้ว

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่พบ Token หรือ User ID')));
      setState(() {
        isLoading = false;
      });
      return;
    }

    String? error = await ApiService.joinEvent(event.id, userId, token);
    if (error == null) {
      setState(() {
        event = Event(
          id: event.id,
          title: event.title,
          description: event.description,
          date: event.date,
          createdBy: event.createdBy,
          imageUrl: event.imageUrl,
          participantCount: event.participantCount + 1,
          isJoined: true,
        );
        isLoading = false;
      });
      widget.onEventUpdated(event);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เข้าร่วมกิจกรรมสำเร็จ')));
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถเข้าร่วมกิจกรรมได้: $error')));
    }
  }

  Future<void> _cancelJoinEvent() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่พบ Token หรือ User ID')));
      setState(() {
        isLoading = false;
      });
      return;
    }

    String? error = await ApiService.cancelJoinEvent(event.id, userId, token);
    if (error == null) {
      setState(() {
        event = Event(
          id: event.id,
          title: event.title,
          description: event.description,
          date: event.date,
          createdBy: event.createdBy,
          imageUrl: event.imageUrl,
          participantCount: event.participantCount > 0 ? event.participantCount - 1 : 0,
          isJoined: false,
        );
        isLoading = false;
      });
      widget.onEventUpdated(event);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ยกเลิกการเข้าร่วมกิจกรรมสำเร็จ')));
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถยกเลิกการเข้าร่วมกิจกรรมได้: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดกิจกรรม'),
        actions: [
          if (isAdmin) // แสดงปุ่มสำหรับแอดมินเพื่อดูรายชื่อผู้เข้าร่วม
            IconButton(
              icon: Icon(Icons.people),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipantsPage(event: event),
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.imageUrl != null)
                Image.network(
                  event.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16),
              Text(
                event.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.date_range, color: Colors.blue),
                  SizedBox(width: 5),
                  Text(
                    "${event.date.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.access_time, color: Colors.blue),
                  SizedBox(width: 5),
                  Text(
                    "${TimeOfDay.fromDateTime(event.date).format(context)}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.people, color: Colors.blue),
                  SizedBox(width: 5),
                  Text(
                    "ผู้เข้าร่วม: ${event.participantCount}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: event.isJoined ? _cancelJoinEvent : _joinEvent,
                        child: Text(event.isJoined ? 'ยกเลิกการเข้าร่วม' : 'เข้าร่วมกิจกรรม'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
