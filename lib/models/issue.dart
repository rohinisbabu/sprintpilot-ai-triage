import '../core/utils/file_picker.dart';

enum IssueStatus { draft, analyzing, analyzed }

class AIAnalysisResult {
  const AIAnalysisResult({
    required this.severity,
    required this.confidence,
    required this.module,
    required this.rootCause,
    required this.suggestedFix,
    required this.duplicateProbability,
    required this.estimatedEffort,
    this.suggestedAssignee = 'Rohini',
    this.engineeringFixes = const [],
  });

  final String severity;
  final String confidence;
  final String module;
  final String rootCause;
  final String suggestedFix;
  final String duplicateProbability;
  final String estimatedEffort;
  final String suggestedAssignee;
  final List<String> engineeringFixes;

  Map<String, String> toMap() {
    return {
      'severity': severity,
      'confidence': confidence,
      'module': module,
      'rootCause': rootCause,
      'suggestedFix': suggestedFix,
      'duplicateProbability': duplicateProbability,
      'estimatedEffort': estimatedEffort,
      'suggestedAssignee': suggestedAssignee,
      'engineeringFixes': engineeringFixes.join('\n'),
    };
  }
}

class GeneratedTicket {
  const GeneratedTicket({
    required this.id,
    required this.title,
    required this.severity,
    required this.module,
    required this.summary,
    required this.acceptanceCriteria,
    required this.engineeringNotes,
    required this.impactEstimate,
    required this.tags,
    this.suggestedAssignee = 'Rohini',
  });

  final String id;
  final String title;
  final String severity;
  final String module;
  final String summary;
  final List<String> acceptanceCriteria;
  final List<String> engineeringNotes;
  final String impactEstimate;
  final List<String> tags;
  final String suggestedAssignee;

  String toExportText() {
    return '''SprintPilot AI Engineering Ticket

Ticket ID: $id
Severity: $severity
Module: $module
Suggested Assignee: $suggestedAssignee

Root Cause:
$summary

Acceptance Criteria:
- ${acceptanceCriteria.join('\n- ')}

Engineering Notes:
- ${engineeringNotes.join('\n- ')}
''';
  }
}

class SprintInsight {
  const SprintInsight({
    required this.confidence,
    required this.recommendation,
    required this.summary,
  });

  final String confidence;
  final String recommendation;
  final String summary;
}

class Issue {
  const Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.crashLog,
    required this.evidence,
    required this.createdAt,
    this.status = IssueStatus.draft,
    this.analysis,
    this.ticket,
    this.sprintInsight,
  });

  final String id;
  final String title;
  final String description;
  final String crashLog;
  final UploadedEvidence? evidence;
  final DateTime createdAt;
  final IssueStatus status;
  final AIAnalysisResult? analysis;
  final GeneratedTicket? ticket;
  final SprintInsight? sprintInsight;

  Issue copyWith({
    String? id,
    String? title,
    String? description,
    String? crashLog,
    UploadedEvidence? evidence,
    DateTime? createdAt,
    IssueStatus? status,
    AIAnalysisResult? analysis,
    GeneratedTicket? ticket,
    SprintInsight? sprintInsight,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      crashLog: crashLog ?? this.crashLog,
      evidence: evidence ?? this.evidence,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      ticket: ticket ?? this.ticket,
      sprintInsight: sprintInsight ?? this.sprintInsight,
    );
  }
}
