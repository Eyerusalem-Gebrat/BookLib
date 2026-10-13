import 'package:flutter/material.dart';
import 'package:booklib_app/screens/login_screen.dart';

// The first screen when nobody is logged in: one Log in button
class LandingScreen extends StatelessWidget {
  // An optional message, e.g. "Your session has expired."
  final String? notice;

  const LandingScreen({super.key, this.notice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'BookLib',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Track every book you read.',
                textAlign: TextAlign.center,
              ),
              if (notice != null) ...[
                const SizedBox(height: 16),
                Text(
                  notice!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Log in'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'New here? Create your account on the BookLib website.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}