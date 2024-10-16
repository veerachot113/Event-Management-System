// screens/event_detail.dart
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'participants.dart'; // นำเข้าไฟล์สำหรับหน้าแสดงรายชื่อผู้เข้าร่วม

class EventDetailPage extends StatefulWidget {
  final Event event;
  final Function(Event) onEventUpdated;

  const EventDetailPage({super.key, required this.event, required this.onEventUpdated});

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
          participants: updatedEvent.participants,
          location: updatedEvent.location, // อัปเดตฟิลด์ location
        );
      });

      // ส่งข้อมูลอัปเดตกลับไปยัง EventsPage เมื่อกลับไปหน้าเดิม
      widget.onEventUpdated(event);
    }
  }

  Future<void> _removeParticipant(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบ Token')));
      return;
    }

    String? error = await ApiService.removeParticipant(event.id, userId, token);
    if (error == null) {
      await _refreshEvent();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบผู้เข้าร่วมสำเร็จ')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถลบผู้เข้าร่วมได้: $error')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบ Token หรือ User ID')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เข้าร่วมกิจกรรมสำเร็จ')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบ Token หรือ User ID')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยกเลิกการเข้าร่วมกิจกรรมสำเร็จ')));
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
        title: const Text('รายละเอียดกิจกรรม'),
        actions: [
          if (isAdmin) // แสดงปุ่มสำหรับแอดมินเพื่อดูรายชื่อผู้เข้าร่วม
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipantsPage(
                      event: event,
                      onRemoveParticipant: (userId) async {
                        await _removeParticipant(userId);
                        // รีเฟรชกิจกรรมหลังจากลบผู้เข้าร่วม
                        await _refreshEvent();
                      },
                    ),
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
              const SizedBox(height: 16),
              Text(
                event.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.place, color: Colors.green),
                  const SizedBox(width: 5),
                  Text(
                    "สถานที่: ${event.location ?? 'ไม่ระบุ'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(
                    "เริ่ม: ${event.startDate.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(event.startDate).format(context)}", // แสดงวันและเวลาเริ่มต้น
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.red),
                  const SizedBox(width: 5),
                  Text(
                    "สิ้นสุด: ${event.endDate.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(event.endDate).format(context)}", // แสดงวันและเวลาสิ้นสุด
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.blue),
                  const SizedBox(width: 5),
                  Text(
                    "ผู้เข้าร่วม: ${event.participantCount}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: event.isJoined ? _cancelJoinEvent : _joinEvent,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(event.isJoined ? 'ยกเลิกการเข้าร่วม' : 'เข้าร่วมกิจกรรม'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
