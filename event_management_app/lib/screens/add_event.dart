// screens/add_event.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../models/event.dart';

class AddEventPage extends StatefulWidget {
  final String token;
  final Function(Event) onEventAdded;

  AddEventPage({required this.token, required this.onEventAdded});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Uint8List? _imageData;
  String? _imageName;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imageData = result.files.first.bytes;
        _imageName = result.files.first.name;
      });
    }
  }

  void addEvent(BuildContext context) async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาเลือกวันและเวลา')));
      return;
    }

    DateTime eventDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final response = await ApiService.addEvent(
      titleController.text,
      descriptionController.text,
      eventDateTime,
      widget.token,
      _imageData, // ส่งข้อมูลรูปภาพ
      _imageName, // ส่งชื่อไฟล์รูปภาพ
    );

  if (response != null) {
    // สร้าง Event ใหม่จากการตอบกลับ
    Event newEvent = Event(
      id: response['id'],
      title: response['title'],
      description: response['description'],
      date: DateTime.parse(response['date']),
      createdBy: response['createdBy'],
      imageUrl: response['image'] != null
          ? 'http://127.0.0.1:8090/api/files/events/${response['id']}/${response['image']}'
          : null,
    );

    widget.onEventAdded(newEvent);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่มกิจกรรมสำเร็จ: ${response['title']}')));
    Navigator.pop(context); // กลับไปยังหน้า Events
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่มกิจกรรมไม่สำเร็จ')));
    print('Error: เพิ่มกิจกรรมไม่สำเร็จ');
  }
}

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มกิจกรรม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // เพิ่มเพื่อรองรับการเลื่อน
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'ชื่อกิจกรรม',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'รายละเอียดกิจกรรม',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: selectedDate != null
                                    ? 'เลือกวันที่: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                                    : 'เลือกวันที่',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectTime(context),
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: selectedTime != null
                                    ? 'เลือกเวลา: ${selectedTime!.format(context)}'
                                    : 'เลือกเวลา',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.access_time),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _imageData != null
                      ? Image.memory(_imageData!, height: 150)
                      : Text('ยังไม่ได้เลือกภาพ'),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('เลือกภาพ'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => addEvent(context),
                    child: Text('เพิ่มกิจกรรม'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
