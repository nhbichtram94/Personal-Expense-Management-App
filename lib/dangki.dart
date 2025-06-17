import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DangKi extends StatefulWidget {
  @override
  _DangKiState createState() => _DangKiState();
}

class _DangKiState extends State<DangKi> {
  final _formkey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _matkhau = TextEditingController();
  final _xacnhanmatkhau = TextEditingController();
  final _sdt = TextEditingController();
  final _email = TextEditingController();

  Future<void> dangki_firebase() async {
    try {
      final newUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _email.text,
            password: _matkhau.text,
          );
      final uid = newUser.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _name.text,
        'email': _email.text,
        'matkhau': _matkhau.text,
        'sdt': _sdt.text,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Lỗi"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/background.jpg", fit: BoxFit.cover),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo.jpg",
                          height: 200,
                          width: 200,
                        ),
                        _buildTextField("Họ và Tên", _name, Icons.person),
                        _buildPasswordField("Mật khẩu", _matkhau),
                        _buildPasswordField(
                          "Xác Nhận Mật Khẩu",
                          _xacnhanmatkhau,
                          isConfirm: true,
                        ),
                        _buildTextField("Số Điện Thoại", _sdt, Icons.phone),
                        _buildTextField(
                          "Email",
                          _email,
                          Icons.email,
                          isEmail: true,
                        ),
                        SizedBox(height: 20),
                        _buildButton("Đăng Ký", dangki_firebase),
                        SizedBox(height: 20),
                        _buildButton("Đăng Nhập", () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Vui lòng nhập $label";
          if (isEmail &&
              !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(value)) {
            return "Vui lòng nhập email hợp lệ";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller, {
    bool isConfirm = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Vui lòng nhập $label";
          if (isConfirm && value != _matkhau.text) return "Mật khẩu không khớp";
          return null;
        },
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.blue,
      ),
      onPressed: () {
        if (text == "Đăng Ký") {
          if (_formkey.currentState?.validate() ?? false) {
            dangki_firebase();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Đăng ký thành công')));
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Có lỗi trong form')));
          }
        } else {
          onPressed();
        }
      },
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}
