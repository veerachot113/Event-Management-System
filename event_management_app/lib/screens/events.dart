import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/event.dart';
import 'add_event.dart';
import 'edit_event.dart';
import 'login.dart';

class EventsPage extends StatefulWidget {
  final String token;
  final bool isAdmin;
  final String userId; // เพิ่ม userId

  EventsPage({required this.token, required this.isAdmin, required this.userId}); // อัปเดต constructor

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

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedEvents = await ApiService.getEvents();
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete event')));
    }
  }

  void joinOrLeaveEvent(int index) async {
    bool alreadyJoined = events[index].participants.contains(widget.userId);
    
    if (alreadyJoined) {
      // ทำการยกเลิกการเข้าร่วม
      bool success = await ApiService.leaveEvent(events[index].id, widget.userId, widget.token);
      if (success) {
        setState(() {
          events[index].participants.remove(widget.userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ยกเลิกการเข้าร่วมกิจกรรม')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถยกเลิกการเข้าร่วมกิจกรรมได้')));
      }
    } else {
      // ทำการเข้าร่วมกิจกรรม
      bool success = await ApiService.joinEvent(events[index].id, widget.userId, widget.token);
      if (success) {
        setState(() {
          events[index].participants.add(widget.userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เข้าร่วมกิจกรรมเรียบร้อย')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถเข้าร่วมกิจกรรมได้')));
      }
    }
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
            // ฟังก์ชันออกจากระบบ
          },
        ),
      ],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              bool alreadyJoined = events[index].participants.contains(widget.userId); // เช็คว่าผู้ใช้เข้าร่วมกิจกรรมหรือไม่
              return ListTile(
                title: Text(events[index].title),
                subtitle: Text(events[index].description),
                trailing: ElevatedButton(
                  onPressed: () async {
                    bool success;
                    if (alreadyJoined) {
                      // หากผู้ใช้เข้าร่วมอยู่แล้ว
                      success = await ApiService.leaveEvent(events[index].id, widget.userId, widget.token);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ยกเลิกการเข้าร่วมกิจกรรม')));
                      }
                    } else {
                      // หากผู้ใช้ยังไม่ได้เข้าร่วม
                      success = await ApiService.joinEvent(events[index].id, widget.userId, widget.token);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เข้าร่วมกิจกรรมเรียบร้อย')));
                      }
                    }
                    setState(() {
                      // อัปเดตสถานะการเข้าร่วมใน UI
                      if (success) {
                        if (alreadyJoined) {
                          events[index].participants.remove(widget.userId);
                        } else {
                          events[index].participants.add(widget.userId);
                        }
                      }
                    });
                  },
                  child: Text(alreadyJoined ? 'ยกเลิก' : 'เข้าร่วม'), // ปรับปุ่มตามสถานะ
                ),
              );
            },
          ),
    floatingActionButton: widget.isAdmin
        ? FloatingActionButton(
            onPressed: () {
              // ฟังก์ชันเพิ่มกิจกรรม
            },
            child: Icon(Icons.add),
          )
        : null,
  );
}
}
