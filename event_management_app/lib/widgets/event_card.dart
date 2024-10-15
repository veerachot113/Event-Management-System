// event_card.dart
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;

  EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(event.description),
        trailing: Text(event.date.toLocal().toString()),
        onTap: () {
          // ฟังก์ชันเข้าร่วมกิจกรรมหรือยกเลิก
        },
      ),
    );
  }
}

