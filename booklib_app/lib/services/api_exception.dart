import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// An error we can show to the user (a wrong password, a validation message...)
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  // Per-field validation messages, e.g. {"title": "The title field is required."}
  final Map<String, String> fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  // True when the token is missing, expired, or revoked
  bool get isUnauthorized => statusCode == 401;

  // Builds a friendly error from a failed Laravel response
  factory ApiException.fromResponse(http.Response response) {
    // The full technical details go to the developer console only
    debugPrint('API error ${response.statusCode}: ${response.body}');

    String? serverMessage;
    final fieldErrors = <String, String>{};

    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final errors = body['errors'];
        if (errors is Map) {
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              fieldErrors[key.toString()] = value.first.toString();
            }
          });
        }
        if (body['message'] is String) {
          serverMessage = body['message'] as String;
        }
      }
    } catch (_) {
      // The body wasn't JSON: use the defaults below
    }

    final String message;
    if (fieldErrors.isNotEmpty) {
      message = fieldErrors.values.first;
    } else {
      message = switch (response.statusCode) {
        403 => serverMessage ?? 'You are not allowed to do that.',
        404 => 'That item could not be found. It may have been deleted.',
        429 => 'Too many attempts. Please wait a moment and try again.',
        >= 500 => 'The server had a problem. Please try again later.',
        _ => serverMessage ?? 'Something went wrong (${response.statusCode}).',
      };
    }

    return ApiException(
      message,
      statusCode: response.statusCode,
      fieldErrors: fieldErrors,
    );
  }

  @override
  String toString() => message;
}