// screens/edit_event.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../models/event.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class EditEventPage extends StatefulWidget {
  final Event event;
  final String token;
  final Function(Event) onEventUpdated;

  const EditEventPage({super.key, required this.event, required this.token, required this.onEventUpdated});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  DateTime? selectedStartDateTime;
  DateTime? selectedEndDateTime;
  Uint8List? _imageData;
  String? _imageName;
  String? existingImageUrl;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;
    locationController.text = widget.event.location ?? '';
    selectedStartDateTime = widget.event.startDate;
    selectedEndDateTime = widget.event.endDate;
    existingImageUrl = widget.event.imageUrl;
  }


Future<void> _pickImage() async {
  try {
    // ขอสิทธิ์เฉพาะบนมือถือ
    if (!kIsWeb) {
      // ตรวจสอบสิทธิ์
      var status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('ต้องการสิทธิ์ในการเข้าถึงรูปภาพ'),
              action: SnackBarAction(
                label: 'ตั้งค่า',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      }
    }

    // เลือกรูปภาพ
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
      allowCompression: true,
      onFileLoading: (FilePickerStatus status) => print('Status: $status'),
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      print('File picked: ${file.name}');
      print('File size: ${file.size}');

      setState(() {
        _imageData = file.bytes;
        _imageName = file.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เลือกรูปภาพสำเร็จ')),
      );
    }
  } catch (e) {
    print('Error picking image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ: $e')),
    );
  }
}

  void updateEvent(BuildContext context) async {
    if (selectedStartDateTime == null || selectedEndDateTime == null || locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกวันเริ่มต้น, สิ้นสุด และกรอกสถานที่')));
      return;
    }

    if (selectedStartDateTime!.isAfter(selectedEndDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('วันเริ่มต้นต้องไม่หลังวันสิ้นสุด')));
      return;
    }

    final response = await ApiService.updateEvent(
      widget.event.id,
      titleController.text,
      descriptionController.text,
      selectedStartDateTime!,
      selectedEndDateTime!,
      locationController.text,
      widget.token,
      _imageData,
      _imageName,
    );

    if (response != null && response is Map<String, dynamic>) {
      Event updatedEvent = Event(
        id: widget.event.id,
        title: response['title'],
        description: response['description'],
        startDate: DateTime.parse(response['startDate']),
        endDate: DateTime.parse(response['endDate']),
        createdBy: response['createdBy'],
        imageUrl: response['image'] != null
            ? 'https://men-cow.pockethost.io/api/files/events/${response['id']}/${response['image']}'
            : null,
        participantCount: response['participantCount'] ?? widget.event.participantCount,
        isJoined: widget.event.isJoined,
        location: response['location'],
      );

      widget.onEventUpdated(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขกิจกรรมสำเร็จ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('แก้ไขกิจกรรมไม่สำเร็จ')));
    }
  }

  Future<void> _selectStartDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDateTime?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedStartDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          selectedStartDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDateTime?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedEndDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          selectedEndDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขกิจกรรม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'ชื่อกิจกรรม', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'รายละเอียดกิจกรรม', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'สถานที่', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectStartDateTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: selectedStartDateTime != null
                          ? 'เลือกวันและเวลาเริ่มต้น: ${selectedStartDateTime!.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(selectedStartDateTime!).format(context)}'
                          : 'เลือกวันและเวลาเริ่มต้น',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectEndDateTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: selectedEndDateTime != null
                          ? 'เลือกวันและเวลาสิ้นสุด: ${selectedEndDateTime!.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(selectedEndDateTime!).format(context)}'
                          : 'เลือกวันและเวลาสิ้นสุด',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _imageData != null
                  ? Image.memory(_imageData!, height: 150)
                  : existingImageUrl != null
                      ? Image.network(existingImageUrl!, height: 150)
                      : const Text('ยังไม่ได้เลือกภาพ'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('เลือกภาพ'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => updateEvent(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('บันทึกการแก้ไข'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
