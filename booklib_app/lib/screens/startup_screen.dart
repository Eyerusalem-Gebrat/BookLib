import 'package:flutter/material.dart';
import 'package:booklib_app/screens/home_screen.dart';
import 'package:booklib_app/screens/landing_screen.dart';
import 'package:booklib_app/services/auth_service.dart';

// The first thing the app shows: decides where to go
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final state = await AuthService().checkSession();
    if (!mounted) return;

    // loggedOut -> landing. active or unknown -> the books
    final Widget next = state == SessionState.loggedOut
        ? const LandingScreen()
        : const HomeScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}