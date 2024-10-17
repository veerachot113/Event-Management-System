// screens/participants.dart
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParticipantsPage extends StatefulWidget {
  final Event event;
  final Function(String) onRemoveParticipant;

  const ParticipantsPage({super.key, required this.event, required this.onRemoveParticipant});

  @override
  _ParticipantsPageState createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  late List<String> participants;
  Map<String, String> userNames = {}; // Map เพื่อเก็บ userId -> username
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    participants = widget.event.participants;
    _fetchUsernames();
  }

  Future<void> _fetchUsernames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      for (String userId in participants) {
        String? username = await ApiService.getUsernameFromUserId(userId, token);
        if (username != null) {
          setState(() {
            userNames[userId] = username;
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _removeParticipant(String userId) async {
    await widget.onRemoveParticipant(userId);
    setState(() {
      participants.remove(userId); // อัปเดตรายการเมื่อผู้เข้าร่วมถูกลบออก
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายชื่อผู้เข้าร่วม: ${widget.event.title}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : participants.isEmpty
              ? const Center(child: Text('ไม่มีผู้เข้าร่วมกิจกรรมนี้'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    String userId = participants[index];
                    String displayName = userNames[userId] ?? userId;

                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(displayName),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeParticipant(userId);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
