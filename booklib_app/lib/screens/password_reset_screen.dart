import 'package:flutter/material.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/password_service.dart';
import 'package:booklib_app/utils/reset_link.dart';
import 'package:booklib_app/screens/login_screen.dart';
import 'package:booklib_app/services/auth_service.dart';

// TEMPORARY: a screen to test the password logic. Antigravity will replace it.
class PasswordTesterScreen extends StatefulWidget {
  const PasswordTesterScreen({super.key});

  @override
  State<PasswordTesterScreen> createState() => _PasswordTesterScreenState();
}

class _PasswordTesterScreenState extends State<PasswordTesterScreen> {
  final _service = PasswordService();
  final _email = TextEditingController();
  final _link = TextEditingController();
  final _newPassword = TextEditingController(text: 'NewPass123!');
  String _output = 'Fill in the fields and press a button.';

  @override
  void dispose() {
    _email.dispose();
    _link.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() => _output = 'Working...');

    String result;
    try {
      result = await action();
    } on ApiException catch (e) {
      result = 'ERROR ${e.statusCode}: ${e.message}\nFields: ${e.fieldErrors}';
    } catch (e) {
      result = 'ERROR: $e';
    }

    if (!mounted) return;
    setState(() => _output = result);
  }

  Future<String> _forgot() => _service.forgotPassword(_email.text.trim());

  Future<String> _parse() async {
    final parsed = ResetLink.parse(_link.text);
    return 'token: ${parsed.token}\nemail: ${parsed.email}';
  }

  Future<String> _reset() async {
    final parsed = ResetLink.parse(_link.text);
    final email = parsed.email ?? _email.text.trim();

    final message = await _service.resetPassword(
      email: email,
      token: parsed.token,
      password: _newPassword.text,
      passwordConfirmation: _newPassword.text,
    );

    // Success: forget any saved login, then go to the login screen
    await AuthService().logout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen(notice: message)),
        (route) => false,
      );
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password tests')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _link,
            decoration:
                const InputDecoration(labelText: 'Pasted link or token'),
          ),
          TextField(
            controller: _newPassword,
            decoration: const InputDecoration(labelText: 'New password'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                  onPressed: () => _run(_forgot),
                  child: const Text('Send reset link')),
              FilledButton.tonal(
                  onPressed: () => _run(_parse),
                  child: const Text('Parse link')),
              FilledButton(
                  onPressed: () => _run(_reset),
                  child: const Text('Reset password')),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(_output),
        ],
      ),
    );
  }
}