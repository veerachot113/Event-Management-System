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

  const EventCard({super.key, 
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
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  // แสดงสถานที่ถ้ามี
                  Row(
                    children: [
                      Icon(Icons.place, color: Colors.green),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range, color: Colors.blue),
                          const SizedBox(width: 5),
                          Text(
                            "${event.startDate.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(event.startDate).format(context)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.date_range, color: Colors.red),
                          const SizedBox(width: 5),
                          Text(
                            "${event.endDate.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(event.endDate).format(context)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.blue),
                      const SizedBox(width: 5),
                      Text(
                        "ผู้เข้าร่วม: ${event.participantCount}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isAdmin)
              OverflowBar(
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
                    child: const Text('แก้ไข'),
                  ),
                  TextButton(
                    onPressed: () {
                      // แสดง Dialog ยืนยันการลบ
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('ยืนยันการลบ'),
                            content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบกิจกรรมนี้?'),
                            actions: [
                              TextButton(
                                child: const Text('ยกเลิก'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('ลบ'),
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
                    child: const Text('ลบ'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
