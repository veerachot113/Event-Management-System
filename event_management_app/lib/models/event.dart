// models/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final String? imageUrl;
  late final int participantCount;
  late final bool isJoined;
  final List<String> participants;
  final String location; // เพิ่มฟิลด์สำหรับสถานที่

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    this.imageUrl,
    this.participantCount = 0,
    this.isJoined = false,
    this.participants = const [],
    required this.location, // ระบุว่าเป็น required
  });
}
