import 'package:flutter/material.dart';
import 'package:quanlythuchi/dangnhap.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DangNhap(),
    );
  }
}
