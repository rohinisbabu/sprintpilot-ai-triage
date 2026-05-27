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
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/section_header.dart';
import '../../services/workspace_settings.dart';

class ReleaseNotesPage extends ConsumerWidget {
  const ReleaseNotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.pagePadding(context);
    final settings = ref.watch(workspaceSettingsProvider);
    final isExecutive = settings.executiveReleaseNotes;
    final copy = isExecutive
        ? _ReleaseNotesCopy.executive()
        : _ReleaseNotesCopy.technical();
    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: SectionHeader(
                          eyebrow: 'Release Notes',
                          title: 'Executive-ready release summary',
                          subtitle:
                              'Generated from triaged tickets, grouped for customer success, product, and leadership updates.',
                        ),
                      ),
                      if (!isMobile) const SizedBox(width: 20),
                      if (!isMobile) _Actions(notesText: copy.exportText),
                    ],
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 18),
                    _Actions(notesText: copy.exportText),
                  ],
                  const SizedBox(height: 26),
                  GridView.count(
                    crossAxisCount: isMobile ? 1 : 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 2.5 : 1.4,
                    children: const [
                      MetricCard(
                        value: '12',
                        label: 'Issues summarized',
                        icon: Icons.summarize_outlined,
                      ),
                      MetricCard(
                        value: '4',
                        label: 'Critical fixes',
                        icon: Icons.security_update_good_rounded,
                        color: AppColors.critical,
                      ),
                      MetricCard(
                        value: '2.1h',
                        label: 'Saved in reporting',
                        icon: Icons.timer_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ReadinessSummary(body: copy.readinessSummary),
                  const SizedBox(height: 18),
                  _NotesGroup(
                    title: 'Bug Fixes',
                    icon: Icons.bug_report_outlined,
                    items: copy.bugFixes,
                  ),
                  _NotesGroup(
                    title: 'Improvements',
                    icon: Icons.trending_up_rounded,
                    items: copy.improvements,
                  ),
                  _NotesGroup(
                    title: 'Known Issues',
                    icon: Icons.info_outline_rounded,
                    items: copy.knownIssues,
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

class _ReadinessSummary extends StatelessWidget {
  const _ReadinessSummary({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.success,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.success.withValues(alpha: .22),
              ),
            ),
            child: const Icon(Icons.verified_rounded, color: AppColors.success),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Release Readiness Summary',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 8),
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

class _Actions extends StatelessWidget {
  const _Actions({required this.notesText});

  final String notesText;

  Future<void> _downloadNotes(BuildContext context) async {
    await downloadFile('release_notes_v2.4.0.md', notesText, 'text/markdown');
    if (!context.mounted) return;
    _showSnack(context, 'Release notes downloaded');
  }

  Future<void> _copyNotes(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: notesText));
    if (!context.mounted) return;
    _showSnack(context, 'Release notes copied to clipboard');
  }

  Future<void> _shareNotes(BuildContext context) async {
    final previewLength = notesText.length > 180 ? 180 : notesText.length;
    final shareText = '''Release Notes v2.4.0

${notesText.substring(0, previewLength)}...''';
    try {
      await Share.share(shareText, subject: 'SprintPilot AI Release Notes');
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: shareText));
    }
    if (!context.mounted) return;
    _showSnack(context, 'Release notes share text copied');
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        GradientButton(
          label: 'Download',
          icon: Icons.download_rounded,
          onPressed: () => _downloadNotes(context),
        ),
        OutlinedButton.icon(
          onPressed: () => _copyNotes(context),
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copy'),
        ),
        OutlinedButton.icon(
          onPressed: () => _shareNotes(context),
          icon: const Icon(Icons.ios_share_rounded),
          label: const Text('Share'),
        ),
      ],
    );
  }
}

class _ReleaseNotesCopy {
  const _ReleaseNotesCopy({
    required this.readinessSummary,
    required this.bugFixes,
    required this.improvements,
    required this.knownIssues,
    required this.exportText,
  });

  final String readinessSummary;
  final List<String> bugFixes;
  final List<String> improvements;
  final List<String> knownIssues;
  final String exportText;

  factory _ReleaseNotesCopy.executive() {
    const bugFixes = [
      'Release readiness improved with stability enhancements across payment workflows.',
      'Customer receipt reliability improved by reducing duplicate confirmation scenarios.',
      'Payment callback resilience increased for users moving between networks.',
    ];
    const improvements = [
      'Leadership visibility improved with clearer release confidence and readiness signals.',
      'Customer success teams receive cleaner impact summaries for payment workflow updates.',
    ];
    const knownIssues = [
      'A small subset of carrier-level network transitions may still delay confirmation by up to five seconds.',
    ];
    const readiness =
        'AI-generated release confidence is 91%. Stability improvements across payment workflows reduce customer-impact risk while QA sign-off remains projected by May 31.';
    return _ReleaseNotesCopy(
      readinessSummary: readiness,
      bugFixes: bugFixes,
      improvements: improvements,
      knownIssues: knownIssues,
      exportText:
          '''# SprintPilot AI Release Notes

## Release Readiness Summary
$readiness

## Bug Fixes
- ${bugFixes[0]}
- ${bugFixes[1]}
- ${bugFixes[2]}

## Improvements
- ${improvements[0]}
- ${improvements[1]}

## Known Issues
- ${knownIssues[0]}
''',
    );
  }

  factory _ReleaseNotesCopy.technical() {
    const bugFixes = [
      'Added callback validation and retry handling in payment module.',
      'Patched duplicate receipt creation in payment retry flow.',
      'Hardened malformed payload handling before callback parsing.',
    ];
    const improvements = [
      'Added network transition telemetry for payment lifecycle debugging.',
      'Improved crash logs with module, device, and callback context.',
    ];
    const knownIssues = [
      'Carrier-level network switches may still delay payment confirmation callbacks by up to five seconds.',
    ];
    const readiness =
        'AI-generated release confidence is 91%. Three blockers remain, with QA sign-off projected by May 31 after payment callback regression coverage lands.';
    return _ReleaseNotesCopy(
      readinessSummary: readiness,
      bugFixes: bugFixes,
      improvements: improvements,
      knownIssues: knownIssues,
      exportText:
          '''# SprintPilot AI Release Notes

## Release Readiness Summary
$readiness

## Bug Fixes
- ${bugFixes[0]}
- ${bugFixes[1]}
- ${bugFixes[2]}

## Improvements
- ${improvements[0]}
- ${improvements[1]}

## Known Issues
- ${knownIssues[0]}
''',
    );
  }
}

class _NotesGroup extends StatelessWidget {
  const _NotesGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
