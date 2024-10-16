// screens/event.dart
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

// EventCard Widget
class EventCard extends StatelessWidget {
  final Event event;
  final bool isAdmin;
  final String token;
  final Function(Event) onEventUpdated;
  final Function(String) onDelete;

  EventCard({
    required this.event,
    required this.isAdmin,
    required this.token,
    required this.onEventUpdated,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          if (event.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                event.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  event.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.date_range, color: Colors.blue),
                        SizedBox(width: 5),
                        Text(
                          "${event.date.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue),
                        SizedBox(width: 5),
                        Text(
                          "${TimeOfDay.fromDateTime(event.date).format(context)}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isAdmin)
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEventPage(
                          event: event,
                          token: token,
                          onEventUpdated: onEventUpdated,
                        ),
                      ),
                    );
                  },
                  child: Text('แก้ไข'),
                ),
                TextButton(
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
                                onDelete(event.id);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('ลบ'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
