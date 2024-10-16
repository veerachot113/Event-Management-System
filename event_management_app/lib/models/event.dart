// models/event.dart
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String createdBy;
  final String? imageUrl; // เพิ่มฟิลด์รูปภาพ

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdBy,
    this.imageUrl,
  });
}
