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
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
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
    if (selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาเลือกวันเริ่มต้นและสิ้นสุด')));
      return;
    }

    if (selectedStartDate!.isAfter(selectedEndDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('วันเริ่มต้นต้องไม่หลังวันสิ้นสุด')));
      return;
    }

    final response = await ApiService.addEvent(
      titleController.text,
      descriptionController.text,
      selectedStartDate!,
      selectedEndDate!,
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
            ? 'http://127.0.0.1:8090/api/files/events/${response['id']}/${response['image']}'
            : null,
      );

      widget.onEventAdded(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่มกิจกรรมสำเร็จ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่มกิจกรรมไม่สำเร็จ')));
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
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
                  GestureDetector(
                    onTap: () => _selectStartDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: selectedStartDate != null
                              ? 'เลือกวันเริ่มต้น: ${selectedStartDate!.toLocal().toString().split(' ')[0]}'
                              : 'เลือกวันเริ่มต้น',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectEndDate(context),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: selectedEndDate != null
                              ? 'เลือกวันสิ้นสุด: ${selectedEndDate!.toLocal().toString().split(' ')[0]}'
                              : 'เลือกวันสิ้นสุด',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
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
