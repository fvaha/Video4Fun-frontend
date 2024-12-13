import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const Video4FunApp());
}

class Video4FunApp extends StatelessWidget {
  const Video4FunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video4Fun',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
