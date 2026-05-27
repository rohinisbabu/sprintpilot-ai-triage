import 'issue.dart';

class TriageRequest {
  const TriageRequest({
    required this.title,
    required this.description,
    required this.crashLog,
  });

  final String title;
  final String description;
  final String crashLog;

  Map<String, String> toJson() {
    return {'title': title, 'description': description, 'crashLog': crashLog};
  }
}

class TriageResponse {
  const TriageResponse({
    required this.severity,
    required this.affectedModule,
    required this.rootCause,
    required this.estimatedSprintImpact,
    required this.suggestedAssignee,
    required this.duplicateProbability,
    required this.suggestedEngineeringFix,
  });

  final String severity;
  final String affectedModule;
  final String rootCause;
  final String estimatedSprintImpact;
  final String suggestedAssignee;
  final String duplicateProbability;
  final List<String> suggestedEngineeringFix;

  factory TriageResponse.fromJson(Map<String, dynamic> json) {
    final fixes = json['suggested_engineering_fix'];
    return TriageResponse(
      severity: _stringValue(json['severity'], fallback: 'Medium'),
      affectedModule: _stringValue(
        json['affected_module'],
        fallback: 'Sprint orchestration',
      ),
      rootCause: _stringValue(
        json['root_cause'],
        fallback: 'AI could not determine a precise root cause.',
      ),
      estimatedSprintImpact: _stringValue(
        json['estimated_sprint_impact'],
        fallback: '2-4 hours',
      ),
      suggestedAssignee: _stringValue(
        json['suggested_assignee'],
        fallback: 'Rohini',
      ),
      duplicateProbability: _stringValue(
        json['duplicate_probability'],
        fallback: '42%',
      ),
      suggestedEngineeringFix: fixes is List
          ? fixes
                .map((item) => item?.toString().trim() ?? '')
                .where((item) => item.isNotEmpty)
                .toList()
          : [
              _stringValue(
                fixes,
                fallback: 'Review failing flow and add regression coverage.',
              ),
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'severity': severity,
      'affected_module': affectedModule,
      'root_cause': rootCause,
      'estimated_sprint_impact': estimatedSprintImpact,
      'suggested_assignee': suggestedAssignee,
      'duplicate_probability': duplicateProbability,
      'suggested_engineering_fix': suggestedEngineeringFix,
    };
  }

  AIAnalysisResult toAnalysisResult() {
    return AIAnalysisResult(
      severity: severity,
      confidence: _confidenceForSeverity(severity),
      module: affectedModule,
      rootCause: rootCause,
      suggestedFix: suggestedEngineeringFix.isEmpty
          ? 'Review issue context and add regression coverage.'
          : suggestedEngineeringFix.join('\n'),
      duplicateProbability: duplicateProbability,
      estimatedEffort: estimatedSprintImpact,
      suggestedAssignee: suggestedAssignee,
      engineeringFixes: suggestedEngineeringFix,
    );
  }

  static String _stringValue(Object? value, {required String fallback}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  static String _confidenceForSeverity(String severity) {
    final normalized = severity.toLowerCase();
    if (normalized.contains('critical')) return '92%';
    if (normalized.contains('high')) return '88%';
    if (normalized.contains('low')) return '82%';
    return '85%';
  }
}
