// screens/event_card.dart
import 'package:event_management_app/screens/edit_event.dart';
import 'package:event_management_app/screens/event_detail.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';

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
      child: InkWell( // เพิ่ม InkWell เพื่อให้สามารถกดได้
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(
                event: event,
                onEventUpdated: onEventUpdated,
              ),
            ),
          );
        },
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
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.blue),
                      SizedBox(width: 5),
                      Text(
                        "ผู้เข้าร่วม: ${event.participantCount}",
                        style: TextStyle(fontSize: 14),
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
                      // นำทางไปยังหน้าการแก้ไขกิจกรรม
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
                      // แสดง Dialog ยืนยันการลบ
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
      ),
    );
  }
}
