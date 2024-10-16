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

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.createdBy,
    this.imageUrl,
    this.participantCount = 0,
    this.isJoined = false,
  });

  // คุณสามารถเพิ่ม factory constructor เพื่อสร้าง Event จาก JSON ได้
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdBy: json['createdBy'],
      imageUrl: json['image'] != null
          ? 'http://127.0.0.1:8090/api/files/events/${json['id']}/${json['image']}'
          : null,
      participantCount: json['participantCount'] ?? 0,
      isJoined: json['isJoined'] ?? false,
    );
  }
}
