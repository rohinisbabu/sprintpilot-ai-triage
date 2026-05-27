import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/download_helper.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/issue.dart';
import '../../services/issue_repository.dart';
import '../../services/mock_ai_analyzer.dart';
import '../../services/sprint_allocation_repository.dart';
import '../../services/workspace_settings.dart';

const _fallbackTicket = GeneratedTicket(
  id: 'BUG-4281',
  title: 'Crash after payment confirmation when switching network',
  severity: 'Critical',
  module: 'Payments',
  summary:
      'Users experience a hard crash on the payment confirmation screen when connectivity changes during callback handling.',
  acceptanceCriteria: [
    'App should not crash during payment callback handling.',
    'Proper error handling is implemented for null callback payloads.',
    'Regression coverage exists for network switching during confirmation.',
  ],
  engineeringNotes: [
    'Add null checks before parsing payment callback payload.',
    'Capture network transition telemetry in crash logs.',
    'Estimated effort: 4-6 hours.',
  ],
  impactEstimate: '4-6 hours',
  tags: ['payments', 'critical', 'ai-generated'],
  suggestedAssignee: 'Arun',
);

class GeneratedTicketPage extends ConsumerWidget {
  const GeneratedTicketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.pagePadding(context);
    final issue = ref.watch(activeIssueProvider);
    final ticket =
        issue?.ticket ??
        (issue == null
            ? _fallbackTicket
            : const MockAiAnalyzer().generateTicket(issue));
    final settings = ref.watch(workspaceSettingsProvider);
    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    eyebrow: 'Generated Ticket',
                    title: 'Jira-ready engineering ticket',
                    subtitle:
                        'Clean technical description, acceptance criteria, priority, and tags generated from QA evidence.',
                  ),
                  const SizedBox(height: 26),
                  _TicketCard(
                    ticket: ticket,
                    jiraExportFormat: settings.jiraExportFormat,
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

class _TicketCard extends ConsumerStatefulWidget {
  const _TicketCard({required this.ticket, required this.jiraExportFormat});

  final GeneratedTicket ticket;
  final bool jiraExportFormat;

  @override
  ConsumerState<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends ConsumerState<_TicketCard> {
  bool _isAssigning = false;

  String get _ticketText {
    final ticket = widget.ticket;
    if (!widget.jiraExportFormat) {
      return '''SprintPilot AI Engineering Ticket

Ticket ID: ${ticket.id}
Title: ${ticket.title}

Issue Summary:
${ticket.summary}
''';
    }

    return '''${ticket.toExportText()}

Duplicate Reference:
Possible duplicate detected: BUG-4280

Owner Recommendation:
${ticket.suggestedAssignee} - ${ticket.module}

Engineering Tags:
${ticket.tags.join(', ')}
''';
  }

  Future<void> _copyTicket(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _ticketText));
    if (!context.mounted) return;
    _showSnack(context, 'Ticket copied to clipboard');
  }

  Future<void> _exportTicket(BuildContext context) async {
    await downloadFile(
      '${widget.ticket.id}-ticket.txt',
      _ticketText,
      'text/plain',
    );
    if (!context.mounted) return;
    _showSnack(context, 'Ticket downloaded successfully');
  }

  Future<void> _shareTicket(BuildContext context) async {
    try {
      await Share.share(_ticketText, subject: 'SprintPilot AI Ticket Summary');
    } catch (_) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Share ticket'),
          content: SelectableText(_ticketText),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }
    if (!context.mounted) return;
    _showSnack(context, 'Ticket shared');
  }

  Future<void> _assignToSprint() async {
    if (_isAssigning) return;
    setState(() => _isAssigning = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted || !context.mounted) return;

    final assignment = ref
        .read(sprintAllocationProvider.notifier)
        .assignTicket(widget.ticket);
    setState(() => _isAssigning = false);
    _showSnack(
      context,
      assignment.rebalanced
          ? 'Primary owner overloaded. AI reassigned for sprint balance. ${assignment.ticketId} assigned to ${assignment.assignee}'
          : '${assignment.ticketId} assigned to ${assignment.assignee}. Sprint allocation recalculated',
    );
  }

  void _showSnack(BuildContext context, String message) {
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
    final ticket = widget.ticket;
    ref.watch(sprintAllocationProvider);
    final recommendation = ref
        .read(sprintAllocationProvider.notifier)
        .recommendationFor(ticket);
    return GlassCard(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: ticket.id,
                color: AppColors.primary,
                icon: Icons.confirmation_number_outlined,
              ),
              const SizedBox(width: 10),
              StatusBadge(
                label: '${ticket.severity} Priority',
                color: AppColors.critical,
                icon: Icons.priority_high_rounded,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Copy ticket content',
                onPressed: () => _copyTicket(context),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                tooltip: 'Download engineering ticket',
                onPressed: () => _exportTicket(context),
                icon: const Icon(Icons.download_rounded),
              ),
              IconButton(
                tooltip: 'Share ticket summary',
                onPressed: () => _shareTicket(context),
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            ticket.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Text(
            ticket.summary,
            style: const TextStyle(
              color: AppColors.mutedText,
              height: 1.55,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          _TicketSection(
            title: 'AI Recommended Assignment',
            bullets: [
              'Recommended Owner: ${recommendation.recommendedOwner}',
              'Team: ${recommendation.module}',
              'Current Capacity: ${recommendation.currentCapacity}%',
              'Estimated Fix Time: ${recommendation.estimatedHours}h',
              'AI Confidence: ${recommendation.confidence}',
              recommendation.reason,
            ],
          ),
          const SizedBox(height: 18),
          if (widget.jiraExportFormat) ...[
            _TicketSection(
              title: 'AI-Generated Summary',
              bullets: [
                'Severity: ${ticket.severity}',
                'Affected module: ${ticket.module}',
                'Estimated resolution impact: ${ticket.impactEstimate}',
                'Duplicate reference: BUG-4280',
                'Owner recommendation: ${ticket.suggestedAssignee} - ${ticket.module}',
              ],
            ),
            const SizedBox(height: 18),
            _TicketSection(
              title: 'Acceptance Criteria',
              bullets: ticket.acceptanceCriteria,
            ),
            const SizedBox(height: 18),
            _TicketSection(
              title: 'Engineering Notes',
              bullets: ticket.engineeringNotes,
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final tag in ticket.tags)
                  StatusBadge(label: tag, color: AppColors.primary),
              ],
            ),
          ] else
            _TicketSection(title: 'Issue Summary', bullets: [ticket.summary]),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Tooltip(
                message: 'Copy ticket content',
                child: GradientButton(
                  label: 'Copy',
                  icon: Icons.copy_rounded,
                  onPressed: () => _copyTicket(context),
                ),
              ),
              Tooltip(
                message: 'Download engineering ticket',
                child: OutlinedButton.icon(
                  onPressed: () => _exportTicket(context),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Ticket'),
                ),
              ),
              Tooltip(
                message: 'Share ticket summary',
                child: OutlinedButton.icon(
                  onPressed: () => _shareTicket(context),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Share'),
                ),
              ),
              Tooltip(
                message: 'AI allocate ticket ownership',
                child: OutlinedButton.icon(
                  onPressed: _isAssigning ? null : _assignToSprint,
                  icon: _isAssigning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.assignment_ind_rounded),
                  label: Text(
                    _isAssigning
                        ? 'AI optimizing sprint ownership...'
                        : 'Assign to Sprint',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketSection extends StatelessWidget {
  const _TicketSection({required this.title, required this.bullets});

  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(color: AppColors.mutedText),
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
