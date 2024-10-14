import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_event.dart';
import '../models/event.dart';

class EventsPage extends StatelessWidget {
  final String token; // เพิ่มตัวแปร token

  EventsPage({required this.token}); // อัปเดต constructor เพื่อรับ token

Future<List<Event>> fetchEvents() async {
  return await ApiService.getEvents(); // เรียกใช้ฟังก์ชันที่โหลดกิจกรรม
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการกิจกรรม'),
      ),
      body: FutureBuilder<List<Event>>(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          } else {
            final events = snapshot.data ?? [];
            return ListView.builder(
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
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventPage(token: token)), // ส่ง token ไปยัง AddEventPage
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
