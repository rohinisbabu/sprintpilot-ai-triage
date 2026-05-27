import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/ai_insight_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/section_header.dart';
import '../../services/issue_repository.dart';
import '../../services/sprint_allocation_repository.dart';

class TeamAllocationPage extends ConsumerWidget {
  const TeamAllocationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.pagePadding(context);
    final isMobile = Responsive.isMobile(context);
    final allocation = ref.watch(sprintAllocationProvider);
    final suggestedAssignee = ref.watch(
      activeIssueProvider.select((issue) => issue?.analysis?.suggestedAssignee),
    );

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
                    eyebrow: 'Team Allocation',
                    title: 'Sprint workload distribution by owner and module',
                    subtitle:
                        'AI maps bug ownership to engineering capacity, domain expertise, and QA validation load.',
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: isMobile ? 1 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isMobile ? 2.4 : 2.25,
                    children: [
                      for (final member in allocation.members)
                        _AllocationCard(
                          member: member,
                          isAiRecommended:
                              suggestedAssignee?.toLowerCase() ==
                              member.name.toLowerCase(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AIInsightCard(
                    title: 'AI allocation recommendation',
                    body: ref
                        .read(sprintAllocationProvider.notifier)
                        .sprintRecommendation(),
                    icon: Icons.psychology_alt_rounded,
                    color: AppColors.cyan,
                    badge: allocation.sprintConfidence,
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

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({required this.member, required this.isAiRecommended});

  final TeamMemberAllocation member;
  final bool isAiRecommended;

  @override
  Widget build(BuildContext context) {
    final load = (member.hours / 48).clamp(0.0, 1.0);
    return GlassCard(
      glowColor: member.color,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: member.color.withValues(alpha: .18),
                  child: Text(
                    member.name.characters.first,
                    style: TextStyle(
                      color: member.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${member.role} - ${member.domain}',
                        style: const TextStyle(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${member.hours} assigned sprint hours',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: load,
                backgroundColor: Colors.white.withValues(alpha: .08),
                valueColor: AlwaysStoppedAnimation(member.color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${member.bugs} bug ownership items',
              style: const TextStyle(color: AppColors.mutedText),
            ),
            if (isAiRecommended) ...[
              const SizedBox(height: 8),
              Text(
                'AI-recommended ownership',
                style: TextStyle(
                  color: member.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'AI Assignment Reason',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              member.assignmentReason,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
            if (member.assignments.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Recent AI Assignments',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
              const SizedBox(height: 6),
              for (final assignment in member.assignments.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '${assignment.ticketId} - ${assignment.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
