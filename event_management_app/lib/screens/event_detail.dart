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
    _refreshEvent(); // อัปเดตข้อมูลทันทีที่หน้าโหลด
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
  String? token = prefs.getString('token');

  if (userId != null && token != null) {
    List<Event> updatedEvents = await ApiService.getEvents(userId);
    Event? updatedEvent = updatedEvents.firstWhere((e) => e.id == event.id, orElse: () => event);

    // อัปเดตสถานะการเข้าร่วม
    bool isJoined = updatedEvent.participants.contains(userId);

    setState(() {
      event = Event(
        id: updatedEvent.id,
        title: updatedEvent.title,
        description: updatedEvent.description,
        startDate: updatedEvent.startDate,
        endDate: updatedEvent.endDate,
        createdBy: updatedEvent.createdBy,
        imageUrl: updatedEvent.imageUrl,
        participantCount: updatedEvent.participants.length,
        isJoined: isJoined,
        participants: updatedEvent.participants, location: '',
      );
    });
  }
}


Future<void> _joinEvent() async {
  setState(() {
    isLoading = true;
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? userId = prefs.getString('userId');

  if (token == null || userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่พบ Token หรือ User ID')));
    setState(() {
      isLoading = false; // แก้ไขสถานะเมื่อไม่พบ Token หรือ User ID
    });
    return;
  }

  String? error = await ApiService.joinEvent(event.id, userId, token);
  if (error == null) {
    await _refreshEvent(); // รีเฟรชข้อมูลทันทีหลังเข้าร่วม
    setState(() {
      isLoading = false; // ตั้งสถานะเป็น false เสมอหลังจากดำเนินการเสร็จ
    });
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
      isLoading = false; // แก้ไขสถานะเมื่อไม่พบ Token หรือ User ID
    });
    return;
  }

  String? error = await ApiService.cancelJoinEvent(event.id, userId, token);
  if (error == null) {
    await _refreshEvent(); // รีเฟรชข้อมูลทันทีหลังยกเลิก
    setState(() {
      isLoading = false; // ตั้งสถานะเป็น false เสมอหลังจากดำเนินการเสร็จ
    });
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
                  Icon(Icons.place, color: Colors.green),
                  SizedBox(width: 5),
                  Text(
                    "สถานที่: ${event.location ?? 'ไม่ระบุ'}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.date_range, color: Colors.blue),
                  SizedBox(width: 5),
                  Text(
                    "เริ่ม: ${event.startDate.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.date_range, color: Colors.red),
                  SizedBox(width: 5),
                  Text(
                    "สิ้นสุด: ${event.endDate.toLocal().toString().split(' ')[0]}",
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
