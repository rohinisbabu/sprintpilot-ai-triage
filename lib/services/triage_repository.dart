import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';
import '../models/triage_model.dart';
import 'api_service.dart';

class TriageRepository {
  TriageRepository(this._apiService);

  final ApiService _apiService;
  final Map<String, TriageResponse> _cache = {};

  // Caches repeated issue analysis during the browser session so the app does
  // not trigger duplicate n8n/OpenAI runs for the same title + description.
  Future<TriageResponse> analyzeIssue(Issue issue) async {
    final request = TriageRequest(
      title: issue.title,
      description: issue.description,
      crashLog: issue.crashLog,
    );
    final cacheKey = _cacheKey(request);
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final json = await _apiService.postTriage(request.toJson());
    final response = TriageResponse.fromJson(_triagePayload(json));
    _cache[cacheKey] = response;
    return response;
  }

  Map<String, dynamic> _triagePayload(Map<String, dynamic> json) {
    for (final key in ['output', 'data', 'body']) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
    }
    return json;
  }

  String _cacheKey(TriageRequest request) {
    return [
      request.title.trim().toLowerCase(),
      request.description.trim().toLowerCase(),
      request.crashLog.trim().toLowerCase(),
    ].join('|');
  }
}

final triageRepositoryProvider = Provider<TriageRepository>((ref) {
  return TriageRepository(ref.watch(apiServiceProvider));
});
