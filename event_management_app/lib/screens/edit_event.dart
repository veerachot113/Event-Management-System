import 'package:flutter/material.dart';
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
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;
    selectedDate = widget.event.date;
    selectedTime = TimeOfDay.fromDateTime(widget.event.date);
  }

  void updateEvent(BuildContext context) async {
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

    final response = await ApiService.updateEvent(
      widget.event.id,
      titleController.text,
      descriptionController.text,
      eventDateTime,
      widget.token,
    );

    if (response != null) {
      Event updatedEvent = Event(
        id: widget.event.id,
        title: response['title'],
        description: response['description'],
        date: DateTime.parse(response['date']),
        createdBy: response['createdBy'],
      );

      widget.onEventUpdated(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('แก้ไขกิจกรรมสำเร็จ')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('แก้ไขกิจกรรมไม่สำเร็จ')));
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
      appBar: AppBar(title: Text('แก้ไขกิจกรรม')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'ชื่อกิจกรรม'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'รายละเอียดกิจกรรม'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(selectedDate != null
                        ? 'วันที่: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'เลือกวันที่'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text(selectedTime != null
                        ? 'เวลา: ${selectedTime!.format(context)}'
                        : 'เลือกเวลา'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => updateEvent(context),
              child: Text('บันทึกการแก้ไข'),
            ),
          ],
        ),
      ),
    );
  }
}