// models/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String createdBy;
  final List<String> participants; // ฟิลด์ใหม่สำหรับเก็บผู้เข้าร่วม

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdBy,
    this.participants = const [], // กำหนดค่าเริ่มต้นเป็นลิสต์ว่าง
  });
}
