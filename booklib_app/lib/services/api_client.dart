
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:booklib_app/config/api_config.dart';
import 'package:booklib_app/services/api_exception.dart';
import 'package:booklib_app/services/session_manager.dart';
import 'package:booklib_app/services/token_storage.dart';

// The one place that sends authenticated requests to the Laravel API.
class ApiClient {
  static const _timeout = Duration(seconds: 20);

  // Runs a network action and turns network failures into friendly ApiExceptions.
  static Future<T> guard<T>(
    Future<T> Function() action, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      return await action().timeout(timeout);
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

  // Every request carries the token:
  // Authorization: Bearer <token>
  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.read();

    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET request.
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

  // DELETE request.
  Future<dynamic> delete(String path) async {
    final headers = await _headers();

    final response = await guard(
      () => http.delete(_uri(path), headers: headers),
    );

    return _handle(response);
  }

  // JSON POST, used for requests such as forgot/reset password.
  Future<dynamic> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _headers();
    headers['Content-Type'] = 'application/json';

    final response = await guard(
      () => http.post(
        _uri(path),
        headers: headers,
        body: jsonEncode(body),
      ),
    );

    return _handle(response);
  }

  // Multipart POST for text fields and an optional image.
  // Image bytes make this compatible with Flutter Web.
  Future<dynamic> postMultipart(
    String path,
    Map<String, String> fields, {
    List<int>? fileBytes,
    String? fileName,
    String fileField = 'poster',
  }) async {
    final headers = await _headers();

    final response = await guard(
      () async {
        final request = http.MultipartRequest(
          'POST',
          _uri(path),
        );

        request.headers.addAll(headers);
        request.fields.addAll(fields);

        // Attach the image only when both its bytes and filename exist.
        if (fileBytes != null && fileName != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              fileField,
              fileBytes,
              filename: fileName,
            ),
          );
        }

        final streamedResponse = await request.send();

        return await http.Response.fromStream(streamedResponse);
      },
      timeout: const Duration(seconds: 60),
    );

    return _handle(response);
  }

  // Convert the server response into JSON data or throw an ApiException.
  dynamic _handle(
    http.Response response, {
    bool expireOn401 = true,
  }) {
    if (response.statusCode == 401) {
      // An invalid/expired token sends the user back to the start screen.
      if (expireOn401) {
        unawaited(SessionManager.expire());
      }

      throw const ApiException(
        'Your session has expired. Please log in again.',
        statusCode: 401,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException.fromResponse(response);
    }

    if (response.body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException(
        'The server sent an unexpected reply. Please try again.',
      );
    }
  }
}
