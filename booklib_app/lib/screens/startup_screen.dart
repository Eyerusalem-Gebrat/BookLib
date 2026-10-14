import 'package:flutter/material.dart';
import 'package:booklib_app/screens/home_screen.dart';
import 'package:booklib_app/screens/landing_screen.dart';
import 'package:booklib_app/services/auth_service.dart';

// The first thing the app shows: checks the saved login, then decides where to go
class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final _auth = AuthService();
  bool _checking = true; // true = spinner, false = the retry screen

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final state = await _auth.checkSession();
    if (!mounted) return;

    switch (state) {
      case SessionState.active:
        _go(const HomeScreen()); // verified by the server
      case SessionState.loggedOut:
        _go(const LandingScreen()); // no token, or the server rejected it
      case SessionState.unknown:
        setState(() => _checking = false); // can't tell: stay and show retry
    }
  }

  // Called by the "Try again" button
  Future<void> _retry() async {
    setState(() => _checking = true);
    await _check();
  }

  // Called by the "Log out" button on the retry screen
  Future<void> _logOut() async {
    await _auth.logout();
    if (!mounted) return;
    _go(const LandingScreen());
  }

  void _go(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.cloud_off, size: 64),
              const SizedBox(height: 16),
              Text(
                "Can't reach BookLib",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your login is saved. Check your connection and try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _retry,
                child: const Text('Try again'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _logOut,
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}