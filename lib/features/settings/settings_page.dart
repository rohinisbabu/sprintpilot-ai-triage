import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/section_header.dart';
import '../../services/workspace_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.pagePadding(context);
    final settings = ref.watch(workspaceSettingsProvider);
    final controller = ref.read(workspaceSettingsProvider.notifier);
    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    eyebrow: 'Settings',
                    title: 'Workspace intelligence controls',
                    subtitle:
                        'Configure SprintPilot AI for Jira exports, release note tone, triage confidence, and engineering workflow preferences.',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    settings.statusText,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SettingCard(
                    title: 'AI confidence threshold',
                    body:
                        'Require 85% confidence before auto-generating Jira-ready ticket drafts.',
                    icon: Icons.verified_user_outlined,
                    value: settings.requireHighConfidence,
                    onChanged: (value) {
                      controller.setRequireHighConfidence(value);
                      _showSnack(
                        context,
                        value
                            ? 'AI confidence threshold enabled'
                            : 'AI confidence threshold disabled',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _SettingCard(
                    title: 'Release note audience',
                    body:
                        'Executive summary with product, customer success, and engineering details.',
                    icon: Icons.article_outlined,
                    color: AppColors.secondary,
                    value: settings.executiveReleaseNotes,
                    onChanged: (value) {
                      controller.setExecutiveReleaseNotes(value);
                      _showSnack(context, 'Release note audience updated');
                    },
                  ),
                  const SizedBox(height: 16),
                  _SettingCard(
                    title: 'Jira export format',
                    body:
                        'Include acceptance criteria, affected module, severity, duplicate match, and owner recommendation.',
                    icon: Icons.data_object_rounded,
                    color: AppColors.cyan,
                    value: settings.jiraExportFormat,
                    onChanged: (value) {
                      controller.setJiraExportFormat(value);
                      _showSnack(
                        context,
                        value
                            ? 'Jira export format enabled'
                            : 'Jira export format disabled',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.color = AppColors.primary,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: color,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
