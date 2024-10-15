// main.dart
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/events.dart';
import 'services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: AuthService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return EventsPage(token: snapshot.data!); // ถ้ามี token ให้ไปยังหน้า Events
          } else {
            return LoginPage(); // ไม่มี token ให้ไปยังหน้า Login
          }
        },
      ),
    );
  }
}
