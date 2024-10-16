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
      home: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            String token = snapshot.data!['token'];
            bool isAdmin = snapshot.data!['isAdmin'];
            return EventsPage(token: token, isAdmin: isAdmin);
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
