import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _triageWebhook = Uri.parse(
    'https://sprintplan.app.n8n.cloud/webhook/triage',
  );

  final http.Client _client;

  // Production n8n webhook integration. The request is intentionally small:
  // the webhook owns AI orchestration, prompt logic, and OpenAI response shape.
  Future<Map<String, dynamic>> postTriage(Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            _triageWebhook,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ApiException('AI analysis failed. Please retry.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) return first;
      }
      throw const ApiException('AI analysis returned an empty response.');
    } on TimeoutException {
      throw const ApiException('AI analysis timed out. Please retry.');
    } on FormatException {
      throw const ApiException('AI analysis returned invalid JSON.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('AI analysis failed. Please retry.');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
