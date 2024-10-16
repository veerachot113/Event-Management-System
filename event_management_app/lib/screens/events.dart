// screens/events.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_event.dart';
import 'edit_event.dart';
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
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: events[index].imageUrl != null
                        ? Image.network(
                            events[index].imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.event),
                    title: Text(events[index].title),
                    subtitle: Text(events[index].description),
                    trailing: widget.isAdmin
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditEventPage(
                                        event: events[index],
                                        token: widget.token,
                                        onEventUpdated: onEventUpdated,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('ยืนยันการลบ'),
                                        content: Text('คุณแน่ใจหรือไม่ว่าต้องการลบกิจกรรมนี้?'),
                                        actions: [
                                          TextButton(
                                            child: Text('ยกเลิก'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('ลบ'),
                                            onPressed: () {
                                              deleteEvent(events[index].id);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
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
