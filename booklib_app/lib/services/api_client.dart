import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:booklib_app/config/api_config.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/session_manager.dart';
import 'package:booklib_app/services/token_storage.dart';

// The one place that sends authenticated requests to the Laravel API
class ApiClient {
  static const _timeout = Duration(seconds: 20);

  // Runs a network action and turns network failures into friendly ApiExceptions
  static Future<T> guard<T>(
    Future<T> Function() action, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      return await action().timeout(timeout);
    } on SocketException {
      throw const ApiException(
        'No connection to the server. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not connect to the server. Please try again.',
      );
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    }
  }

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  // Every request carries the token: Authorization: Bearer <token>
  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.read();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(
    String path, {
    Duration timeout = _timeout,
    bool expireOn401 = true,
  }) async {
    final headers = await _headers();
    final response = await guard(
      () => http.get(_uri(path), headers: headers),
      timeout: timeout,
    );
    return _handle(response, expireOn401: expireOn401);
  }

  Future<dynamic> delete(String path) async {
    final headers = await _headers();
    final response = await guard(
      () => http.delete(_uri(path), headers: headers),
    );
    return _handle(response);
  }

  // A JSON POST (used for forgot/reset password)
  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';

    final response = await guard(
      () => http.post(_uri(path), headers: headers, body: jsonEncode(body)),
    );
    return _handle(response);
  }

  // A form submission (text fields + an optional file), sent as POST
  Future<dynamic> postMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String fileField = 'poster',
  }) async {
    final headers = await _headers();

    final response = await guard(
      () async {
        final request = http.MultipartRequest('POST', _uri(path));
        request.headers.addAll(headers);
        request.fields.addAll(fields);

        if (file != null) {
          request.files.add(
            await http.MultipartFile.fromPath(fileField, file.path),
          );
        }

        final streamed = await request.send();
        return http.Response.fromStream(streamed);
      },
      timeout: const Duration(seconds: 60), // uploads can be slower
    );
    return _handle(response);
  }

  // Turns a response into JSON data, or throws an ApiException
  dynamic _handle(http.Response response, {bool expireOn401 = true}) {
    if (response.statusCode == 401) {
      // The token is invalid: send the user back to the start screen
      if (expireOn401) unawaited(SessionManager.expire());
      throw const ApiException(
        'Your session has expired. Please log in again.',
        statusCode: 401,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }

    if (response.body.isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException(
        'The server sent an unexpected reply. Please try again.',
      );
    }
  }
}