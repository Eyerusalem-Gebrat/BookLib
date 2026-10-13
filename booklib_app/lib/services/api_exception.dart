import 'dart:convert';
import 'package:http/http.dart' as http;

// An error we show to the user (a wrong password, a validation message...)
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  // Builds a readable message from a failed Laravel response
  factory ApiException.fromResponse(http.Response response) {
    var message = 'Something went wrong (${response.statusCode}).';

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      // Validation errors: {"errors": {"email": ["The provided credentials are incorrect."]}}
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          message = first.first.toString();
        }
      } else if (body['message'] is String) {
        // Other errors: {"message": "Unauthenticated."}
        message = body['message'] as String;
      }
    } catch (_) {
      // The body wasn't JSON: keep the default message
    }

    return ApiException(message, statusCode: response.statusCode);
  }

  @override
  String toString() => message;
}