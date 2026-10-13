import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:booklib_app/config/api_config.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/token_storage.dart';

class AuthService {
  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // POST /api/login, then save the token on the phone
  Future<void> login(String email, String password) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/login'),
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] ?? data['access_token'];

    if (token is! String || token.isEmpty) {
      throw ApiException(
        'The server did not return a token. Response: ${response.body}',
      );
    }

    await TokenStorage.save(token);
  }

  // POST /api/logout (revokes the token on the server), then forget it locally
  Future<void> logout() async {
    final token = await TokenStorage.read();

    if (token != null) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/logout'),
          headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 15));
      } catch (_) {
        // Even if the server can't be reached, we still log out on the phone
      }
    }

    await TokenStorage.clear();
  }
}