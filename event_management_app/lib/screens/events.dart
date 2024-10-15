// events.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_event.dart';
import '../models/event.dart';
import 'login.dart';

class EventsPage extends StatefulWidget {
  final String token;
  final bool isAdmin;

  EventsPage({required this.token, required this.isAdmin});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> events = []; // ใช้ List เพื่อเก็บกิจกรรม
  bool isLoading = true; // ใช้ตัวแปรเพื่อติดตามสถานะการโหลด

  @override
  void initState() {
    super.initState();
    fetchEvents(); // เรียกใช้ฟังก์ชันเพื่อโหลดกิจกรรมเมื่อเริ่มต้น
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true; // เริ่มการโหลด
    });

    try {
      final fetchedEvents = await ApiService.getEvents(); // โหลดกิจกรรม
      setState(() {
        events = fetchedEvents; // อัปเดตรายการกิจกรรม
        isLoading = false; // สิ้นสุดการโหลด
      });
    } catch (error) {
      setState(() {
        isLoading = false; // สิ้นสุดการโหลดแม้เกิดข้อผิดพลาด
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching events: $error')));
    }
  }

  void onEventAdded(Event newEvent) {
    setState(() {
      events.add(newEvent); // เพิ่มกิจกรรมใหม่ในรายการ
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการกิจกรรม'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
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
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index].title),
                  subtitle: Text(events[index].description),
                  onTap: () {
                    // ฟังก์ชันเข้าร่วมกิจกรรมหรือยกเลิก
                  },
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
                      onEventAdded: onEventAdded, // ส่ง callback
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




