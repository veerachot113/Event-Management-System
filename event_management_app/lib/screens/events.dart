import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'event_detail.dart';
import '../models/event.dart';
import 'add_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class EventsPage extends StatefulWidget {
  final String token;
  final bool isAdmin;

  const EventsPage({super.key, required this.token, required this.isAdmin});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> events = [];
  List<Event> filteredEvents = [];
  bool isLoading = true;
  final searchController = TextEditingController();

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('ไม่พบ User ID');
      }

      final fetchedEvents = await ApiService.getEvents(userId);
      setState(() {
        events = fetchedEvents;
        filteredEvents = fetchedEvents;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching events: $error')));
    }
  }

  void filterEvents(String query) {
    setState(() {
      filteredEvents = events.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void onEventAdded(Event newEvent) {
    setState(() {
      events.add(newEvent);
      filteredEvents.add(newEvent);
    });
  }

  void updateEvent(Event updatedEvent) {
    setState(() {
      int index = events.indexWhere((e) => e.id == updatedEvent.id);
      if (index != -1) {
        events[index] = updatedEvent;
        filteredEvents = events.where((event) {
          return event.title.toLowerCase().contains(searchController.text.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการกิจกรรม'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchEvents,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหากิจกรรม',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => filterEvents(value),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchEvents,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailPage(
                                  event: filteredEvents[index],
                                  onEventUpdated: updateEvent, // ใช้ฟังก์ชัน updateEvent
                                ),
                              ),
                            );
                          },
                          child: EventCard(event: filteredEvents[index]),
                        );
                      },
                    ),
                  ),
          ),
        ],
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
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.blue),
                      const SizedBox(width: 5),
                      Text(
                        "${event.startDate.toLocal().toString().split(' ')[0]} - ${event.endDate.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.people, color: Colors.blue),
                      const SizedBox(width: 5),
                      Text(
                        "ผู้เข้าร่วม: ${event.participantCount}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
