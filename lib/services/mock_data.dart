import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class MockIssue {
  const MockIssue({
    required this.id,
    required this.title,
    required this.module,
    required this.severity,
    required this.status,
    required this.time,
    required this.color,
  });

  final String id;
  final String title;
  final String module;
  final String severity;
  final String status;
  final String time;
  final Color color;
}

class MockData {
  const MockData._();

  static const analysis = (
    severity: 'Critical',
    confidence: 92,
    module: 'Payments Service',
    rootCause: 'Null pointer exception in payment callback handler.',
    suggestedAction:
        'Guard payment callback payloads, add retry-safe error handling, and capture carrier transition telemetry.',
  );

  static const steps = [
    'Open checkout and complete payment authorization.',
    'Wait for confirmation callback to begin.',
    'Switch from WiFi to mobile data during callback resolution.',
    'Observe crash on the payment confirmation screen.',
  ];

  static const processingSteps = [
    'Analyzing screenshot',
    'Detecting severity',
    'Identifying root cause',
    'Mapping affected module',
    'Generating engineering summary',
    'Creating Jira-ready ticket',
  ];

  static const issues = [
    MockIssue(
      id: 'BUG-4281',
      title: 'Crash after payment confirmation on network change',
      module: 'Payments',
      severity: 'Critical',
      status: 'Triaged',
      time: '18m ago',
      color: AppColors.critical,
    ),
    MockIssue(
      id: 'BUG-4279',
      title: 'Duplicate receipt generated for retry flow',
      module: 'Billing',
      severity: 'High',
      status: 'In progress',
      time: '42m ago',
      color: AppColors.warning,
    ),
    MockIssue(
      id: 'BUG-4272',
      title: 'Slow search after account migration',
      module: 'Search',
      severity: 'Medium',
      status: 'Resolved',
      time: '2h ago',
      color: AppColors.primary,
    ),
  ];

  static const teamMembers = [
    (
      name: 'Rohini',
      role: 'Technical Lead',
      domain: 'Sprint orchestration',
      hours: 34,
      bugs: 5,
      color: AppColors.cyan,
    ),
    (
      name: 'Arun',
      role: 'Developer',
      domain: 'Payments',
      hours: 42,
      bugs: 9,
      color: AppColors.critical,
    ),
    (
      name: 'Neha',
      role: 'Developer',
      domain: 'Authentication',
      hours: 31,
      bugs: 4,
      color: AppColors.primary,
    ),
    (
      name: 'Rahul',
      role: 'Developer',
      domain: 'Checkout',
      hours: 28,
      bugs: 3,
      color: AppColors.success,
    ),
    (
      name: 'Anjali',
      role: 'Developer',
      domain: 'Notifications',
      hours: 24,
      bugs: 2,
      color: AppColors.secondary,
    ),
    (
      name: 'Vivek',
      role: 'Developer',
      domain: 'API Services',
      hours: 36,
      bugs: 6,
      color: AppColors.warning,
    ),
    (
      name: 'Priya',
      role: 'QA Team',
      domain: 'Mobile QA',
      hours: 30,
      bugs: 7,
      color: AppColors.primary,
    ),
    (
      name: 'Joseph',
      role: 'QA Team',
      domain: 'Regression QA',
      hours: 27,
      bugs: 5,
      color: AppColors.cyan,
    ),
  ];

  static const Map<String, dynamic> generatedTicket = {
    'id': 'BUG-4281',
    'title': 'Crash after payment confirmation when switching network',
    'severity': 'Critical',
    'module': 'Payments Service',
    'duplicate': 'BUG-4280',
    'estimatedImpact':
        '4-6 engineering hours to fix and validate regression paths',
    'summary':
        'Users experience a hard crash on the payment confirmation screen when connectivity changes from WiFi to mobile data during callback handling.',
    'acceptanceCriteria': [
      'App should not crash during payment confirmation while switching networks.',
      'Null pointer safety must be added to the payment callback handler.',
      'Regression coverage should validate payment retry flows.',
    ],
    'engineeringNotes': [
      'Add callback payload null guard in Payments Service.',
      'Capture network transition telemetry in payment callback logs.',
      'Add regression coverage for network switching during confirmation.',
    ],
    'tags': ['payments', 'mobile-network', 'crash', 'ai-generated'],
  };

  static const String releaseNotesMarkdown = '''# Release Notes v2.4.0

## Bug Fixes
- Fixed payment confirmation crash during WiFi to mobile data transitions.
- Resolved duplicate receipt creation in the payment retry flow.
- Improved defensive handling for malformed callback payloads.

## Improvements
- Added network transition telemetry for payment lifecycle debugging.
- Improved crash logs with module, device, and callback context.

## Known Issues
- Some carrier-level network switches may still delay confirmation by up to five seconds.

## Summary
SprintPilot AI generated a 91% confidence release summary with 12 issues summarized and executive-ready notes for product, leadership, and customer success stakeholders.
''';

  static const String sprintSummaryReport = '''Sprint Summary Report

- Total Issues: 248
- Critical Bugs: 18
- Resolved Tickets: 196
- Sprint Velocity: 42
- Release Confidence: 91%

AI insight: Payments ownership is 18% above planned allocation. Shift 3 payment bugs to Rahul to reduce sprint bottleneck risk and preserve release confidence above 90%.

Prepared by SprintPilot AI operations console.
''';
}
