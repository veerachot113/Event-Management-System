// models/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String createdBy;
  final String? imageUrl;
  final int participantCount;
  final bool isJoined;
  final List<String> participants; // เพิ่มฟิลด์นี้เพื่อเก็บชื่อหรือ ID ของผู้เข้าร่วม

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdBy,
    this.imageUrl,
    this.participantCount = 0,
    this.isJoined = false,
    this.participants = const [], // เริ่มต้นเป็นลิสต์ว่าง
  });
}
