import 'package:flutter/material.dart';
import 'package:booklib_app/screens/landing_screen.dart';
import 'package:booklib_app/services/token_storage.dart';

// Lets code that isn't a screen change screens (used by main.dart too)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SessionManager {
  SessionManager._();

  static bool _handling = false;

  // Called when the server says the token is no longer valid (401)
  static Future<void> expire() async {
    if (_handling) return; // several requests may fail at the same moment
    _handling = true;

    await TokenStorage.clear();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LandingScreen(
          notice: 'Your session has expired. Please log in again.',
        ),
      ),
      (route) => false,
    );

    _handling = false;
  }
}