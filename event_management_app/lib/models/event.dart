// models/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate; // เพิ่มฟิลด์วันเริ่มต้น
  final DateTime endDate;   // เพิ่มฟิลด์วันสิ้นสุด
  final String createdBy;
  final String? imageUrl;
  late final int participantCount;
  late final bool isJoined;
  final List<String> participants;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate, // ใช้วันเริ่มต้น
    required this.endDate,   // ใช้วันสิ้นสุด
    required this.createdBy,
    this.imageUrl,
    this.participantCount = 0,
    this.isJoined = false,
    this.participants = const [],
  });

  get date => null;
}
