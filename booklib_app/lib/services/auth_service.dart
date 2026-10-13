import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:booklib_app/config/api_config.dart';
import 'package:booklib_app/services/api_client.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/token_storage.dart';

// The result of checking the saved login when the app starts
enum SessionState {
  loggedOut, // no token, or the server says it is no longer valid
  active, // the server accepted the token
  unknown, // the server could not be reached: we can't tell
}

class AuthService {
  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // POST /api/login, then save the token on the phone
  Future<void> login(String email, String password) async {
    final response = await ApiClient.guard(
      () => http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      ),
      timeout: const Duration(seconds: 15),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }

    Object? token;
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      token = data['token'] ?? data['access_token'];
    } catch (_) {
      throw const ApiException(
        'The server sent an unexpected reply. Please try again.',
      );
    }

    if (token is! String || token.isEmpty) {
      throw const ApiException(
        'The server did not return a login token. Please try again.',
      );
    }

    await TokenStorage.save(token);
  }

  // POST /api/logout (revokes the token on the server), then forget it locally
  Future<void> logout() async {
    final token = await TokenStorage.read();

    if (token != null) {
      try {
        await ApiClient.guard(
          () => http.post(
            Uri.parse('${ApiConfig.baseUrl}/logout'),
            headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
          ),
          timeout: const Duration(seconds: 10),
        );
      } catch (_) {
        // Even if the server can't be reached, we still log out on the phone
      }
    }

    await TokenStorage.clear();
  }

  // Used at startup: is the saved token still valid?
  Future<SessionState> checkSession() async {
    final token = await TokenStorage.read();
    if (token == null) return SessionState.loggedOut;

    try {
      // Any protected request will do; a 401 means the token is dead
      await ApiClient().get(
        '/books',
        timeout: const Duration(seconds: 8),
        expireOn401: false,
      );
      return SessionState.active;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await TokenStorage.clear();
        return SessionState.loggedOut;
      }
      return SessionState.unknown;
    } catch (_) {
      return SessionState.unknown;
    }
  }
}