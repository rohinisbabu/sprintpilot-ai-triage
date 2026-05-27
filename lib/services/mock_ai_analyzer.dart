import '../models/issue.dart';

class MockAiAnalyzer {
  const MockAiAnalyzer();

  Future<AIAnalysisResult> analyze(Issue issue) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final text = '${issue.title} ${issue.description} ${issue.crashLog}'
        .toLowerCase();
    final module = text.contains('auth') || text.contains('login')
        ? 'Authentication'
        : text.contains('checkout') || text.contains('cart')
        ? 'Checkout'
        : text.contains('api') || text.contains('server')
        ? 'API Services'
        : 'Payments';
    final severity =
        text.contains('crash') ||
            text.contains('critical') ||
            text.contains('payment')
        ? 'Critical'
        : text.contains('slow') || text.contains('timeout')
        ? 'High'
        : 'Medium';
    return AIAnalysisResult(
      severity: severity,
      confidence: severity == 'Critical'
          ? '92%'
          : severity == 'High'
          ? '86%'
          : '82%',
      module: module,
      rootCause: module == 'Payments'
          ? 'Null callback guard missing'
          : 'Unhandled state transition detected in ${module.toLowerCase()} flow',
      suggestedFix: module == 'Payments'
          ? 'Add null checks before parsing'
          : 'Add defensive state checks and regression coverage',
      duplicateProbability: severity == 'Critical' ? '78%' : '54%',
      estimatedEffort: severity == 'Critical' ? '4-6 hours' : '2-4 hours',
      suggestedAssignee: module == 'Payments'
          ? 'Arun'
          : module == 'Checkout'
          ? 'Rahul'
          : module == 'Authentication'
          ? 'Neha'
          : module == 'API Services'
          ? 'Vivek'
          : 'Rohini',
      engineeringFixes: [
        module == 'Payments'
            ? 'Add null checks before parsing'
            : 'Add defensive state checks and regression coverage',
      ],
    );
  }

  GeneratedTicket generateTicket(Issue issue) {
    final analysis =
        issue.analysis ??
        const AIAnalysisResult(
          severity: 'Critical',
          confidence: '92%',
          module: 'Payments',
          rootCause: 'Null callback guard missing',
          suggestedFix: 'Add null checks before parsing',
          duplicateProbability: '78%',
          estimatedEffort: '4-6 hours',
        );
    return GeneratedTicket(
      id: issue.id,
      title: issue.title,
      severity: analysis.severity,
      module: analysis.module,
      summary:
          '${issue.description}\n\nAI identified ${analysis.rootCause.toLowerCase()} with ${analysis.confidence} confidence.',
      acceptanceCriteria: [
        'Issue no longer reproduces with the uploaded evidence scenario.',
        '${analysis.module} flow handles the failing edge case safely.',
        'Regression test covers the reported crash/log condition.',
      ],
      engineeringNotes: [
        ...analysis.engineeringFixes.isEmpty
            ? [analysis.suggestedFix]
            : analysis.engineeringFixes,
        'Review crash log context: ${issue.crashLog.isEmpty ? 'No crash log provided.' : issue.crashLog}',
        'Estimated effort: ${analysis.estimatedEffort}',
      ],
      impactEstimate: analysis.estimatedEffort,
      tags: [
        analysis.module.toLowerCase().replaceAll(' ', '-'),
        analysis.severity.toLowerCase(),
        'ai-generated',
      ],
      suggestedAssignee: analysis.suggestedAssignee,
    );
  }

  SprintInsight generateSprintInsight(Issue issue) {
    final analysis = issue.analysis;
    final confidence = analysis?.confidence ?? '91%';
    final module = analysis?.module ?? 'Payments';
    return SprintInsight(
      confidence: confidence,
      recommendation:
          'Reassign one ${module.toLowerCase()} bug to Rahul and reserve QA validation with Priya to keep sprint risk controlled.',
      summary:
          'SprintPilot forecasts ${analysis?.estimatedEffort ?? '4-6 hours'} of engineering effort for ${issue.title}. Release confidence remains $confidence after recommended reassignment.',
    );
  }
}
