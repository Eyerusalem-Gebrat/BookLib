import 'package:flutter/material.dart';
import 'package:booklib_app/screens/startup_screen.dart';
import 'package:booklib_app/services/session_manager.dart';

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
      navigatorKey: navigatorKey, // lets SessionManager change screens
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const StartupScreen(),
    );
  }
}