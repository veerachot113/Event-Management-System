// screens/participants.dart
import 'package:flutter/material.dart';
import '../models/event.dart';

class ParticipantsPage extends StatelessWidget {
  final Event event;

  const ParticipantsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายชื่อผู้เข้าร่วม: ${event.title}'),
      ),
      body: event.participants.isEmpty
          ? const Center(child: Text('ไม่มีผู้เข้าร่วมกิจกรรมนี้'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: event.participants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('User ID: ${event.participants[index]}'),
                );
              },
            ),
    );
  }
}
