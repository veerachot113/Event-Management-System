// screens/edit_event.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../models/event.dart';

class EditEventPage extends StatefulWidget {
  final Event event;
  final String token;
  final Function(Event) onEventUpdated;

  EditEventPage({required this.event, required this.token, required this.onEventUpdated});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController(); // เพิ่ม TextEditingController สำหรับสถานที่
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  Uint8List? _imageData;
  String? _imageName;
  String? existingImageUrl;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;
    locationController.text = widget.event.location ?? ''; // ตั้งค่าเริ่มต้นของสถานที่
    selectedStartDate = widget.event.startDate;
    selectedEndDate = widget.event.endDate;
    existingImageUrl = widget.event.imageUrl;
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imageData = result.files.first.bytes;
        _imageName = result.files.first.name;
        existingImageUrl = null; // ลบภาพเก่าออกจากการแสดงผล
      });
    }
  }

  void updateEvent(BuildContext context) async {
    if (selectedStartDate == null || selectedEndDate == null || locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาเลือกวันเริ่มต้น, สิ้นสุด และกรอกสถานที่')));
      return;
    }

    if (selectedStartDate!.isAfter(selectedEndDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('วันเริ่มต้นต้องไม่หลังวันสิ้นสุด')));
      return;
    }

    final response = await ApiService.updateEvent(
      widget.event.id,
      titleController.text,
      descriptionController.text,
      selectedStartDate!,
      selectedEndDate!,
      locationController.text, // ส่งข้อมูลสถานที่ไปยัง API
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
            ? 'http://127.0.0.1:8090/api/files/events/${response['id']}/${response['image']}'
            : null,
        participantCount: response['participantCount'] ?? widget.event.participantCount,
        isJoined: widget.event.isJoined,
        location: response['location'], // เพิ่มการรับค่าข้อมูลสถานที่
      );

      widget.onEventUpdated(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('แก้ไขกิจกรรมสำเร็จ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('แก้ไขกิจกรรมไม่สำเร็จ')));
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
        title: Text('แก้ไขกิจกรรม'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'ชื่อกิจกรรม', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'รายละเอียดกิจกรรม', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'สถานที่', border: OutlineInputBorder()),
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
                  : existingImageUrl != null
                      ? Image.network(existingImageUrl!, height: 150)
                      : Text('ยังไม่ได้เลือกภาพ'),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('เลือกภาพ'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => updateEvent(context),
                child: Text('บันทึกการแก้ไข'),
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
    );
  }
}
