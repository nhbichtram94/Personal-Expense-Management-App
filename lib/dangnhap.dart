import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quanlythuchi/DangKi.dart';
import 'package:quanlythuchi/quenmk.dart';
import 'package:quanlythuchi/trangchu.dart';

class DangNhap extends StatefulWidget {
  @override
  _DangNhapState createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  final _formkey = GlobalKey<FormState>();
  final _tendangnhap = TextEditingController();
  final _matkhau = TextEditingController();

  Future<void> dangNhapFirebase() async {
    String emailInput = _tendangnhap.text.trim();
    String password = _matkhau.text.trim();
    String emailToLogin = emailInput;

    try {
      // Nếu người dùng nhập tên đăng nhập (không chứa @)
      if (!emailInput.contains('@')) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('tendangnhap', isEqualTo: emailInput)
            .limit(1)
            .get();

        if (userSnapshot.docs.isEmpty) {
          throw Exception('Không tìm thấy người dùng');
        }

        emailToLogin = userSnapshot.docs.first['email'];
      }

      // Đăng nhập bằng email
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailToLogin,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thành công')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Trangchu()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: Sai mật khẩu')),
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
                        Center(
                          child: Image.asset(
                            "assets/images/logo.jpg",
                            height: 200,
                            width: 200,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _tendangnhap,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Vui lòng nhậpemail";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _matkhau,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Mật khẩu",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Vui lòng nhập mật khẩu";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            if (_formkey.currentState?.validate() ?? false) {
                              dangNhapFirebase();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Có lỗi trong form')),
                              );
                            }
                          },
                          child: Text("Đăng Nhập", style: TextStyle(fontSize: 18)),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Quenmk()),
                                );
                              },
                              child: Text("Quên Mật Khẩu", style: TextStyle(fontSize: 18, color: Colors.blue)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DangKi()),
                                );
                              },
                              child: Text("Đăng Ký", style: TextStyle(fontSize: 18, color: Colors.blue)),
                            ),
                          ],
                        )
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
}
