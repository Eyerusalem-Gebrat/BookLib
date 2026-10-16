import 'package:flutter/material.dart';
import 'package:booklib_app/config/app_theme.dart';
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
      return const Scaffold(
        backgroundColor: AppTheme.pageBg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: const [AppTheme.cardShadow],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.badgeIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        size: 32,
                        color: AppTheme.kicker,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Can't reach BookLib",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontSerif,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your login is saved. Check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: const [AppTheme.primaryGlow],
                      ),
                      child: FilledButton(
                        onPressed: _retry,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Try again',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _logOut,
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.btnCardBg,
                          border: Border.all(color: AppTheme.btnCardBorder),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Center(
                          child: Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.btnCardText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}