import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

void main() {
  runApp(const SmartKidsApp());
}

class SmartKidsApp extends StatelessWidget {
  const SmartKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "SmartKids",

      theme: ThemeData(primarySwatch: Colors.blue),

      home: const LoginScreen(),
    );
  }
}
