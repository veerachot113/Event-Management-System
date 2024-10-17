import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'events.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isObscure = true;

  void login(BuildContext context) async {
    if (usernameOrEmailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return;
    }

    final response = await ApiService.login(
      usernameOrEmailController.text,
      passwordController.text,
    );

    if (response != null && response['token'] != null) {
      String token = response['token'];
      bool isAdmin = response['record']['isAdmin'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventsPage(token: token, isAdmin: isAdmin),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดชุดสี
    final primaryColor = Color(0xFF0D47A1);
    final accentColor = Color(0xFFFFA726);

    return Scaffold(
      body: Stack(
        children: [
          // ภาพพื้นหลัง
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('background.jpg'), // เพิ่มภาพพื้นหลังของคุณ
                fit: BoxFit.cover,
              ),
            ),
          ),
          // ชั้นโปร่งแสง
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // เนื้อหา
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // โลโก้หรือชื่อแอป
                    Text(
                      'กิจกรรมสนุก ๆ รอคุณอยู่',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: usernameOrEmailController,
                              style: TextStyle(color: primaryColor),
                              decoration: InputDecoration(
                                labelText: 'ชื่อผู้ใช้หรืออีเมล',
                                labelStyle: TextStyle(color: primaryColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: accentColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(Icons.person, color: primaryColor),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              obscureText: _isObscure,
                              style: TextStyle(color: primaryColor),
                              decoration: InputDecoration(
                                labelText: 'รหัสผ่าน',
                                labelStyle: TextStyle(color: primaryColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: accentColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(Icons.lock, color: primaryColor),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure ? Icons.visibility : Icons.visibility_off,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => login(context),
                              child: Text('เข้าสู่ระบบ'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: accentColor,
                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                                textStyle: TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                            ),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpPage()),
                                );
                              },
                              child: Text(
                                'ยังไม่มีบัญชี? สมัครสมาชิกที่นี่',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
