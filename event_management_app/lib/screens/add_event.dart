// screens/add_event.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../models/event.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
class AddEventPage extends StatefulWidget {
  final String token;
  final Function(Event) onEventAdded;

  const AddEventPage({super.key, required this.token, required this.onEventAdded});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  DateTime? selectedStartDateTime;
  DateTime? selectedEndDateTime;
  Uint8List? _imageData;
  String? _imageName;


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

  void addEvent(BuildContext context) async {
    if (selectedStartDateTime == null || selectedEndDateTime == null || locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกวันเริ่มต้น, สิ้นสุด และกรอกสถานที่')));
      return;
    }

    if (selectedStartDateTime!.isAfter(selectedEndDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('วันเริ่มต้นต้องไม่หลังวันสิ้นสุด')));
      return;
    }

    final response = await ApiService.addEvent(
      titleController.text,
      descriptionController.text,
      selectedStartDateTime!,
      selectedEndDateTime!,
      locationController.text,
      widget.token,
      _imageData,
      _imageName,
    );

    if (response != null) {
      Event newEvent = Event(
        id: response['id'],
        title: response['title'],
        description: response['description'],
        startDate: DateTime.parse(response['startDate']),
        endDate: DateTime.parse(response['endDate']),
        createdBy: response['createdBy'],
        imageUrl: response['image'] != null
            ? 'https://men-cow.pockethost.io/api/files/events/${response['id']}/${response['image']}'
            : null,
        location: response['location'],
      );

      widget.onEventAdded(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มกิจกรรมสำเร็จ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เพิ่มกิจกรรมไม่สำเร็จ')));
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
        title: const Text('เพิ่มกิจกรรม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อกิจกรรม',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'รายละเอียดกิจกรรม',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'สถานที่',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectStartDateTime(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: selectedStartDateTime != null
                              ? 'เริ่ม: ${selectedStartDateTime!.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(selectedStartDateTime!).format(context)}'
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
                              ? 'สิ้นสุด: ${selectedEndDateTime!.toLocal().toString().split(' ')[0]} ${TimeOfDay.fromDateTime(selectedEndDateTime!).format(context)}'
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
                      : const Text('ยังไม่ได้เลือกภาพ'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('เลือกภาพ'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => addEvent(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('เพิ่มกิจกรรม'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
