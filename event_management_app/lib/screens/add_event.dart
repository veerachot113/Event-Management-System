// add_event.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddEventPage extends StatefulWidget {
  final String token; // เพิ่มตัวแปร token

  AddEventPage({required this.token}); // อัปเดต constructor เพื่อรับ token

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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

  print('Event Data: ${jsonEncode({
    'title': titleController.text,
    'description': descriptionController.text,
    'date': eventDateTime.toIso8601String(),
    'createdBy': 'ui5ldqnmu1qt3es', // ใช้ ID ของผู้ดูแลระบบ
  })}');

  final response = await ApiService.addEvent(
    titleController.text,
    descriptionController.text,
    eventDateTime,
    widget.token,
  );

  if (response != null) {
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
      appBar: AppBar(title: Text('เพิ่มกิจกรรม')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
