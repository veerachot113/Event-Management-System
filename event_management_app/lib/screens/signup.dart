import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  bool _isObscure = true;
  bool _isConfirmObscure = true;

  void signUp(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')));
      return;
    }

    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return;
    }

    final response = await ApiService.signUp(
      usernameController.text,
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
    );

    if (response != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('สมัครสมาชิกสำเร็จ')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('สมัครสมาชิกไม่สำเร็จ')));
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
                image: AssetImage('background_signup.jpg'),
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
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ข้อความเชิญชวน
                    Text(
                      'เข้าร่วมกับเราเพื่อสนุกไปด้วยกัน',
                      style: TextStyle(
                        fontSize: 32,
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
                              'สมัครสมาชิก',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: usernameController,
                              style: TextStyle(color: primaryColor),
                              decoration: InputDecoration(
                                labelText: 'ชื่อผู้ใช้',
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
                              controller: emailController,
                              style: TextStyle(color: primaryColor),
                              decoration: InputDecoration(
                                labelText: 'อีเมล',
                                labelStyle: TextStyle(color: primaryColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: accentColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(Icons.email, color: primaryColor),
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
                            SizedBox(height: 16),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: _isConfirmObscure,
                              style: TextStyle(color: primaryColor),
                              decoration: InputDecoration(
                                labelText: 'ยืนยันรหัสผ่าน',
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
                                    _isConfirmObscure ? Icons.visibility : Icons.visibility_off,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmObscure = !_isConfirmObscure;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => signUp(context),
                              child: Text('สมัครสมาชิก'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: accentColor,
                                padding:
                                    EdgeInsets.symmetric(vertical: 15, horizontal: 40),
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
                                Navigator.pop(context);
                              },
                              child: Text(
                                'มีบัญชีอยู่แล้ว? เข้าสู่ระบบที่นี่',
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
