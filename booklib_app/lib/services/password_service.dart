import 'package:booklib_app/services/api_client.dart';
import 'package:booklib_app/services/api_exception.dart';

class PasswordService {
  final ApiClient _api = ApiClient();

  // Step 1: Ask Laravel to send a password-reset link.
  Future<String> forgotPassword(String email) async {
    final data = await _api.postJson('/forgot-password', {
      'email': email.trim(),
    });

    return _message(
      data,
      'If an account exists for this email, a reset link will be sent.',
    );
  }

  // Step 2: Ask Laravel to verify the link pasted by the user.
  // Laravel returns the email and token when the link is valid.
  Future<Map<String, String>> verifyLink(String link) async {
    final data = await _api.postJson('/reset-password/verify', {
      'link': link.trim(),
    });

    if (data is! Map<String, dynamic> ||
        data['email'] is! String ||
        data['token'] is! String) {
      throw const ApiException(
        'The server returned an unexpected reset-link response.',
      );
    }

    return {'email': data['email'] as String, 'token': data['token'] as String};
  }

  // Step 3: Submit the new password to Laravel.
  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _api.postJson('/reset-password', {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    return _message(data, 'Password reset successfully.');
  }

  // Extract Laravel's message from a successful JSON response.
  String _message(dynamic data, String fallback) {
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }

    return fallback;
  }
}
