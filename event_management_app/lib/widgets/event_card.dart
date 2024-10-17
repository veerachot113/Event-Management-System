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

  const EventCard({
    Key? key,
    required this.event,
    required this.isAdmin,
    required this.token,
    required this.onEventUpdated,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: InkWell(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      event.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.description.isNotEmpty)
                    Text(
                      event.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                  const SizedBox(height: 10),
                  // แสดงสถานที่ถ้ามี
                  if (event.location != null && event.location!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.redAccent),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.blueAccent),
                      const SizedBox(width: 5),
                      Text(
                        "${event.startDate.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(event.startDate).format(context)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, size: 16),
                      const SizedBox(width: 10),
                      Text(
                        "${event.endDate.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(event.endDate).format(context)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.green),
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
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('แก้ไข'),
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
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('ลบ'),
                      onPressed: () {
                        // แสดง Dialog ยืนยันการลบ
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('ยืนยันการลบ'),
                              content: const Text(
                                  'คุณแน่ใจหรือไม่ว่าต้องการลบกิจกรรมนี้?'),
                              actions: [
                                TextButton(
                                  child: const Text('ยกเลิก'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
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
