import 'package:booklib_app/services/api_client.dart';

class PasswordService {
  final ApiClient _api = ApiClient();

  // POST /api/forgot-password: asks Laravel to email a reset link
  Future<String> forgotPassword(String email) async {
    final data = await _api.postJson('/forgot-password', {'email': email});
    return _message(
      data,
      'If an account exists for this email, a reset link will be sent.',
    );
  }

  // POST /api/reset-password: sets a new password using the emailed token
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

  // Reads {"message": "..."} from the response
  String _message(dynamic data, String fallback) {
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}