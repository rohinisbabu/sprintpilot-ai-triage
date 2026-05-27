import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/download_helper.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/ai_insight_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/section_header.dart';
import '../../models/issue.dart';
import '../../services/issue_repository.dart';
import '../../services/sprint_allocation_repository.dart';

class SprintInsightsPage extends ConsumerWidget {
  const SprintInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.pagePadding(context);
    final isMobile = Responsive.isMobile(context);
    final issue = ref.watch(activeIssueProvider);
    ref.watch(sprintAllocationProvider);
    final allocationRecommendation = ref
        .read(sprintAllocationProvider.notifier)
        .sprintRecommendation();
    final severity = issue?.analysis?.severity ?? 'Medium';
    final risk = _riskProfile(severity);
    final insight = SprintInsight(
      confidence: risk.releaseConfidence,
      recommendation: allocationRecommendation,
      summary:
          issue?.sprintInsight?.summary ??
          '${issue?.analysis?.estimatedEffort ?? '2-4 hours'} sprint impact forecast from ${issue?.analysis?.module ?? 'AI triage'} severity.',
    );
    final report = _reportText(issue, insight);

    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    eyebrow: 'Sprint Insights',
                    title: 'AI planning intelligence for engineering leaders',
                    subtitle:
                        'SprintPilot forecasts bottlenecks, coordination overhead, and release confidence before they become status meetings.',
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            await downloadFile(
                              'sprint_summary_report.txt',
                              report,
                              'text/plain',
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.card.withValues(
                                  alpha: .94,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                content: const Text(
                                  'Sprint summary report downloaded',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download Report'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final shareText =
                                'Sprint Insights Summary:\n$report';
                            try {
                              await Share.share(
                                shareText,
                                subject: 'SprintPilot AI Summary',
                              );
                            } catch (_) {
                              await Clipboard.setData(
                                ClipboardData(text: shareText),
                              );
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.card.withValues(
                                  alpha: .94,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                content: const Text(
                                  'Sprint insight copied for sharing',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.ios_share_rounded),
                          label: const Text('Share Summary'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: isMobile ? 1 : 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 2.7 : 1.25,
                    children: [
                      MetricCard(
                        value: '37h',
                        label: 'Sprint Hours Saved',
                        icon: Icons.more_time_rounded,
                        color: AppColors.success,
                      ),
                      MetricCard(
                        value: risk.coordinationLoad,
                        label: 'New Coordination Load',
                        icon: Icons.timeline_rounded,
                        color: AppColors.cyan,
                      ),
                      MetricCard(
                        value: risk.bottleneckRisk,
                        label: 'Bottleneck Risks',
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.warning,
                      ),
                      MetricCard(
                        value: risk.releaseConfidence,
                        label: 'Release Confidence',
                        icon: Icons.verified_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AIInsightCard(
                    title: 'Sprint bottleneck forecast',
                    body: allocationRecommendation,
                    icon: Icons.auto_graph_rounded,
                    color: AppColors.secondary,
                    badge: risk.releaseConfidence,
                  ),
                  const SizedBox(height: 18),
                  _VelocityPanel(
                    severity: severity,
                    sprintImpact: issue?.analysis?.estimatedEffort ?? '2-4h',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _reportText(Issue? issue, SprintInsight insight) {
    return '''SprintPilot AI Sprint Impact Summary

Issue: ${issue?.title ?? 'Crash after payment confirmation when switching network'}
Confidence: ${insight.confidence}

Recommendation:
${insight.recommendation}

Summary:
${insight.summary}
''';
  }
}

class _VelocityPanel extends StatelessWidget {
  const _VelocityPanel({required this.severity, required this.sprintImpact});

  final String severity;
  final String sprintImpact;

  @override
  Widget build(BuildContext context) {
    final points = _velocityProjection(
      severity: severity,
      sprintImpact: sprintImpact,
    );
    final maxVelocity = points
        .map((point) => point.velocity)
        .reduce((a, b) => a > b ? a : b);
    return GlassCard(
      glowColor: AppColors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'AI-driven sprint velocity projection',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _severityColor(severity).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _severityColor(severity).withValues(alpha: .24),
                  ),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: _severityColor(severity),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Adjusted from AI sprint impact: $sprintImpact',
            style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: Responsive.isMobile(context) ? 220 : 240,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var index = 0; index < points.length; index++)
                        Expanded(
                          child: _VelocityBar(
                            point: points[index],
                            maxVelocity: maxVelocity,
                            delay: Duration(milliseconds: 70 * index),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final point in points)
                      Expanded(
                        child: Text(
                          point.label,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VelocityBar extends StatelessWidget {
  const _VelocityBar({
    required this.point,
    required this.maxVelocity,
    required this.delay,
  });

  final ({String label, double velocity}) point;
  final double maxVelocity;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final factor = (point.velocity / maxVelocity).clamp(.18, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: factor),
        duration: Duration(milliseconds: 620 + delay.inMilliseconds),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                point.velocity.round().toString(),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: value,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.cyan.withValues(alpha: .92),
                            AppColors.primary,
                            AppColors.secondary.withValues(alpha: .88),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: .22),
                            blurRadius: 18,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: .24),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

List<({String label, double velocity})> _velocityProjection({
  required String severity,
  required String sprintImpact,
}) {
  final base = [46.0, 49, 53, 56, 60, 63];
  final labels = ['D1', 'D2', 'D3', 'D4', 'D5', 'D6'];
  final normalized = severity.toLowerCase();
  final impactHours = _impactHours(sprintImpact);
  final severityDrag = normalized.contains('critical')
      ? 18
      : normalized.contains('high')
      ? 10
      : normalized.contains('low')
      ? -5
      : 4;

  return [
    for (var index = 0; index < base.length; index++)
      (
        label: labels[index],
        velocity: (base[index] - severityDrag - impactHours + index * 1.8)
            .clamp(24.0, 74.0),
      ),
  ];
}

double _impactHours(String sprintImpact) {
  final values = RegExp(
    r'\d+',
  ).allMatches(sprintImpact).map((match) => double.parse(match.group(0)!));
  if (values.isEmpty) return 3;
  return values.reduce((a, b) => a + b) / values.length;
}

Color _severityColor(String severity) {
  final normalized = severity.toLowerCase();
  if (normalized.contains('critical')) return AppColors.critical;
  if (normalized.contains('high')) return AppColors.warning;
  if (normalized.contains('low')) return AppColors.success;
  return AppColors.primary;
}

({String bottleneckRisk, String releaseConfidence, String coordinationLoad})
_riskProfile(String severity) {
  final normalized = severity.toLowerCase();
  if (normalized.contains('critical')) {
    return (
      bottleneckRisk: 'High',
      releaseConfidence: '74%',
      coordinationLoad: '8-12h',
    );
  }
  if (normalized.contains('high')) {
    return (
      bottleneckRisk: 'Medium',
      releaseConfidence: '84%',
      coordinationLoad: '5-8h',
    );
  }
  if (normalized.contains('low')) {
    return (
      bottleneckRisk: 'Low',
      releaseConfidence: '94%',
      coordinationLoad: '1-2h',
    );
  }
  return (
    bottleneckRisk: 'Low',
    releaseConfidence: '89%',
    coordinationLoad: '2-4h',
  );
}
