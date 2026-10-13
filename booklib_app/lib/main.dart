import 'package:flutter/material.dart';
import 'package:booklib_app/screens/login_screen.dart';

void main() {
  runApp(const BookLibApp());
}

class BookLibApp extends StatelessWidget {
  const BookLibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookLib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}