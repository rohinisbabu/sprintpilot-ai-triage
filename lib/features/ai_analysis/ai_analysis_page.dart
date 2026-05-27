import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/issue.dart';
import '../../services/issue_repository.dart';
import '../../services/mock_ai_analyzer.dart';
import '../../services/mock_data.dart';
import '../../services/workspace_settings.dart';

class AiAnalysisPage extends ConsumerWidget {
  const AiAnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.pagePadding(context);
    final issue = ref.watch(activeIssueProvider);
    final analysis = issue?.analysis;

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
                    eyebrow: 'AI Analysis',
                    title: 'Evidence converted into engineering signal',
                    subtitle:
                        'SprintPilot has identified severity, likely root cause, affected module, and reproduction path.',
                  ),
                  const SizedBox(height: 26),
                  Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isMobile ? 0 : 9,
                        child: _ScreenshotEvidence(issue: issue),
                      ),
                      SizedBox(
                        width: isMobile ? 0 : 22,
                        height: isMobile ? 22 : 0,
                      ),
                      Expanded(
                        flex: isMobile ? 0 : 10,
                        child: _InsightsPanel(issue: issue, analysis: analysis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenshotEvidence extends StatelessWidget {
  const _ScreenshotEvidence({required this.issue});

  final Issue? issue;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_search_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Uploaded screenshot',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10172B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: _EvidencePreview(issue: issue)),
                  Positioned(
                    right: 18,
                    top: 18,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.critical.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.critical.withValues(alpha: .35),
                        ),
                      ),
                      child: const Text(
                        'Crash state detected',
                        style: TextStyle(
                          color: AppColors.critical,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidencePreview extends StatelessWidget {
  const _EvidencePreview({required this.issue});

  final Issue? issue;

  @override
  Widget build(BuildContext context) {
    final evidence = issue?.evidence;
    if (evidence != null && evidence.isImage && evidence.bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.memory(
          evidence.bytes,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return _MockEvidenceContent(issue: issue);
          },
        ),
      );
    }

    if (evidence != null && evidence.isPdf) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.secondary,
              size: 58,
            ),
            const SizedBox(height: 14),
            Text(
              evidence.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'PDF evidence analyzed',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ],
        ),
      );
    }

    return _MockEvidenceContent(issue: issue);
  }
}

class _MockEvidenceContent extends StatelessWidget {
  const _MockEvidenceContent({required this.issue});

  final Issue? issue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.critical,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            issue?.title ?? 'Payment callback failed',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
          ),
          const SizedBox(height: 8),
          Text(
            issue?.description ?? 'Network changed during confirmation',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _InsightsPanel extends ConsumerStatefulWidget {
  const _InsightsPanel({required this.issue, required this.analysis});

  final Issue? issue;
  final AIAnalysisResult? analysis;

  @override
  ConsumerState<_InsightsPanel> createState() => _InsightsPanelState();
}

class _InsightsPanelState extends ConsumerState<_InsightsPanel> {
  bool _isGeneratingTicket = false;
  bool _isForecastingSprint = false;

  Future<void> _generateTicket() async {
    if (_isGeneratingTicket) return;
    final issue = widget.issue;
    if (issue == null) {
      _showSnack('Upload an issue before generating a ticket.');
      return;
    }
    final settings = ref.read(workspaceSettingsProvider);
    final confidence = _confidenceValue(
      (issue.analysis ?? widget.analysis)?.confidence ?? '92%',
    );
    if (settings.requireHighConfidence && confidence < 85) {
      _showSnack('AI confidence below threshold. Manual review recommended.');
      return;
    }
    setState(() => _isGeneratingTicket = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final ticket = const MockAiAnalyzer().generateTicket(issue);
    ref.read(issueRepositoryProvider.notifier).saveTicket(issue.id, ticket);
    setState(() => _isGeneratingTicket = false);
    _showSnack('Engineering ticket generated');
    context.go('/ticket');
  }

  Future<void> _viewSprintImpact() async {
    if (_isForecastingSprint) return;
    final issue = widget.issue;
    if (issue == null) {
      _showSnack('Upload an issue before forecasting sprint impact.');
      return;
    }
    setState(() => _isForecastingSprint = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final insight = const MockAiAnalyzer().generateSprintInsight(issue);
    ref
        .read(issueRepositoryProvider.notifier)
        .saveSprintInsight(issue.id, insight);
    setState(() => _isForecastingSprint = false);
    _showSnack('Sprint impact forecast updated');
    context.go('/sprint-insights');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card.withValues(alpha: .94),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final analysis = widget.analysis;
    final settings = ref.watch(workspaceSettingsProvider);
    return _InsightsPanelContent(
      issue: issue,
      analysis: analysis,
      requireHighConfidence: settings.requireHighConfidence,
      isGeneratingTicket: _isGeneratingTicket,
      isForecastingSprint: _isForecastingSprint,
      onGenerateTicket: _generateTicket,
      onViewSprintImpact: _viewSprintImpact,
    );
  }
}

class _InsightsPanelContent extends StatelessWidget {
  const _InsightsPanelContent({
    required this.issue,
    required this.analysis,
    required this.requireHighConfidence,
    required this.isGeneratingTicket,
    required this.isForecastingSprint,
    required this.onGenerateTicket,
    required this.onViewSprintImpact,
  });

  final Issue? issue;
  final AIAnalysisResult? analysis;
  final bool requireHighConfidence;
  final bool isGeneratingTicket;
  final bool isForecastingSprint;
  final VoidCallback onGenerateTicket;
  final VoidCallback onViewSprintImpact;

  @override
  Widget build(BuildContext context) {
    final safeAnalysis =
        analysis ??
        const AIAnalysisResult(
          severity: 'Critical',
          confidence: '92%',
          module: 'Payments',
          rootCause: 'Null callback guard missing',
          suggestedFix: 'Add null checks before parsing',
          duplicateProbability: '78%',
          estimatedEffort: '4-6 hours',
        );
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusBadge(
                label: safeAnalysis.severity,
                color: AppColors.critical,
                icon: Icons.priority_high_rounded,
              ),
              StatusBadge(
                label: '${safeAnalysis.confidence} confidence',
                color: AppColors.success,
                icon: Icons.verified_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ConfidenceGraph(confidence: safeAnalysis.confidence),
          if (requireHighConfidence &&
              _confidenceValue(safeAnalysis.confidence) < 85) ...[
            const SizedBox(height: 18),
            const _ConfidenceWarning(),
          ],
          const SizedBox(height: 18),
          _InsightBlock(
            title: 'Affected module',
            body: safeAnalysis.module,
            icon: Icons.account_tree_outlined,
          ),
          _InsightBlock(
            title: 'Root cause analysis',
            body: safeAnalysis.rootCause,
            icon: Icons.psychology_alt_outlined,
          ),
          _InsightBlock(
            title: 'Duplicate detection',
            body:
                'Possible duplicate detected: BUG-4280 (${safeAnalysis.duplicateProbability} probability)',
            icon: Icons.merge_type_rounded,
          ),
          _InsightBlock(
            title: 'Estimated resolution impact',
            body:
                'Blocks release readiness. AI estimates a ${safeAnalysis.estimatedEffort} fix with regression coverage.',
            icon: Icons.trending_up_rounded,
          ),
          _InsightBlock(
            title: 'Suggested assignee',
            body:
                '${safeAnalysis.suggestedAssignee} is recommended based on module ownership, current sprint load, and fix complexity.',
            icon: Icons.assignment_ind_rounded,
          ),
          const Text(
            'Reproduction steps',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < MockData.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.primary.withValues(alpha: .16),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      MockData.steps[i],
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          _InsightBlock(
            title: 'Suggested action',
            body: safeAnalysis.suggestedFix,
            icon: Icons.tips_and_updates_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: isGeneratingTicket
                      ? 'Generating engineering ticket...'
                      : 'Generate Ticket',
                  icon: Icons.confirmation_number_outlined,
                  expanded: true,
                  onPressed: onGenerateTicket,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: isForecastingSprint ? null : onViewSprintImpact,
                icon: const Icon(Icons.insights_rounded),
                label: Text(
                  isForecastingSprint
                      ? 'Forecasting sprint impact...'
                      : 'View Sprint Impact',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.dashboard_customize_rounded),
                label: const Text('Back to Dashboard'),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                tooltip: 'Save analysis',
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

double _confidenceValue(String confidence) {
  return double.tryParse(confidence.replaceAll('%', '').trim()) ?? 92;
}

class _ConfidenceWarning extends StatelessWidget {
  const _ConfidenceWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.critical.withValues(alpha: .24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.critical.withValues(alpha: .08),
            blurRadius: 24,
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_problem_outlined, color: AppColors.critical),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI confidence below threshold. Manual review recommended.',
              style: TextStyle(color: AppColors.mutedText, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceGraph extends StatelessWidget {
  const _ConfidenceGraph({required this.confidence});

  final String confidence;

  @override
  Widget build(BuildContext context) {
    final numericConfidence = _confidenceValue(confidence);
    final factor = (numericConfidence / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: .12),
            AppColors.primary.withValues(alpha: .07),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: .1),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.query_stats_rounded, color: AppColors.success),
              const SizedBox(width: 10),
              const Text(
                'AI confidence model',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Text(
                confidence,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: Colors.white.withValues(alpha: .08),
                ),
                FractionallySizedBox(
                  widthFactor: factor,
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.success, AppColors.cyan],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
