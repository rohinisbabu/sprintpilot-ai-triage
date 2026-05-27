import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/ai_insight_card.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_lens.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../services/mock_data.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.pagePadding(context);

    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommandHero(
                isMobile: isMobile,
                onNewIssue: () => context.go('/upload'),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(
                eyebrow: 'Sprint overview',
                title:
                    'Operational intelligence across triage, QA, and release',
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: isMobile ? 1 : 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.8 : 1.05,
                children: const [
                  MetricCard(
                    value: '248',
                    label: 'Total Issues',
                    icon: Icons.all_inbox_rounded,
                  ),
                  MetricCard(
                    value: '18',
                    label: 'Critical Bugs',
                    icon: Icons.priority_high_rounded,
                    color: AppColors.critical,
                  ),
                  MetricCard(
                    value: '196',
                    label: 'Resolved Tickets',
                    icon: Icons.verified_rounded,
                    color: AppColors.success,
                  ),
                  MetricCard(
                    value: '42',
                    label: 'Sprint Velocity',
                    icon: Icons.speed_rounded,
                    color: AppColors.cyan,
                  ),
                  MetricCard(
                    value: '91%',
                    label: 'Release Confidence',
                    icon: Icons.timer_rounded,
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _TeamAllocationPanel(),
              const SizedBox(height: 24),
              const _SprintMetricsGrid(),
              const SizedBox(height: 24),
              const _ReleaseReadinessPanel(),
              const SizedBox(height: 24),
              const _RecentIssues(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandHero extends StatelessWidget {
  const _CommandHero({required this.isMobile, required this.onNewIssue});

  final bool isMobile;
  final VoidCallback onNewIssue;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        const StatusBadge(
          label: 'AI monitoring console',
          color: AppColors.cyan,
          icon: Icons.radar_rounded,
        ),
        const SizedBox(height: 16),
        Text(
          'Engineering Ops Command Center',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Monitor AI triage throughput, sprint workload, QA readiness, and release confidence through a live launch-room view.',
          style: TextStyle(color: AppColors.mutedText, height: 1.5),
        ),
        const SizedBox(height: 20),
        GradientButton(
          label: 'New Issue',
          icon: Icons.add_rounded,
          onPressed: onNewIssue,
        ),
      ],
    );

    final visual = GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 30,
      glowColor: AppColors.cyan,
      child: SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final size in [190.0, 142.0, 94.0])
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: .16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .10),
                      blurRadius: 34,
                      spreadRadius: -12,
                    ),
                  ],
                ),
              ),
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withValues(alpha: .18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const GlassLens(
              width: 98,
              height: 98,
              radius: 32,
              child: Icon(Icons.hub_rounded, color: Colors.white, size: 38),
            ),
            const Positioned(
              top: 4,
              right: 8,
              child: StatusBadge(label: 'Live', color: AppColors.success),
            ),
            const Positioned(
              left: 8,
              bottom: 6,
              child: StatusBadge(label: '34s avg', color: AppColors.primary),
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      return Column(children: [copy, const SizedBox(height: 18), visual]);
    }
    return Row(
      children: [
        Expanded(child: copy),
        const SizedBox(width: 22),
        Expanded(child: visual),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: AppColors.cyan,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _TeamAllocationPanel extends StatelessWidget {
  const _TeamAllocationPanel();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          eyebrow: 'Team allocation',
          title: 'AI-balanced engineering ownership for this sprint',
        ),
        const SizedBox(height: 14),
        Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isMobile ? 0 : 7,
              child: GlassCard(
                glowColor: AppColors.cyan,
                child: Column(
                  children: [
                    for (final member in MockData.teamMembers)
                      _TeamMemberRow(member: member),
                  ],
                ),
              ),
            ),
            SizedBox(width: isMobile ? 0 : 18, height: isMobile ? 18 : 0),
            const Expanded(
              flex: 5,
              child: AIInsightCard(
                title: 'Allocation recommendation',
                body:
                    'AI recommends shifting 3 payment bugs from Arun to Rahul to reduce sprint bottleneck risk while keeping checkout velocity stable.',
                icon: Icons.auto_graph_rounded,
                color: AppColors.secondary,
                badge: 'High impact',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  const _TeamMemberRow({required this.member});

  final ({
    String name,
    String role,
    String domain,
    int hours,
    int bugs,
    Color color,
  })
  member;

  @override
  Widget build(BuildContext context) {
    final load = (member.hours / 48).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
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
                  '${member.name} - ${member.domain}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  '${member.role} - ${member.hours}h assigned - ${member.bugs} bugs',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: load,
                    backgroundColor: Colors.white.withValues(alpha: .08),
                    valueColor: AlwaysStoppedAnimation(member.color),
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

class _SprintMetricsGrid extends StatelessWidget {
  const _SprintMetricsGrid();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          eyebrow: 'Sprint metrics',
          title: 'Automation impact on coordination overhead',
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: isMobile ? 1 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 2.8 : 1.35,
          children: const [
            MetricCard(
              value: '37h',
              label: 'Sprint Hours Saved',
              icon: Icons.more_time_rounded,
              color: AppColors.success,
            ),
            MetricCard(
              value: '72%',
              label: 'AI Coordination Reduction',
              icon: Icons.hub_rounded,
              color: AppColors.cyan,
            ),
            MetricCard(
              value: '41',
              label: 'Duplicate Issues Prevented',
              icon: Icons.merge_type_rounded,
              color: AppColors.secondary,
            ),
            MetricCard(
              value: '92%',
              label: 'AI Confidence Score',
              icon: Icons.verified_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _ReleaseReadinessPanel extends StatelessWidget {
  const _ReleaseReadinessPanel();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  eyebrow: 'Release readiness',
                  title: 'Projected ship confidence for Sprint 24.6',
                ),
              ),
              if (!Responsive.isMobile(context))
                const StatusBadge(
                  label: '91% confidence',
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _ReadinessChip('Pending blockers', '3', AppColors.critical),
              _ReadinessChip('QA pending', '7', AppColors.warning),
              _ReadinessChip('Estimated release', 'May 31', AppColors.primary),
              _ReadinessChip('Release confidence', '91%', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadinessChip extends StatelessWidget {
  const _ReadinessChip(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isMobile(context) ? double.infinity : 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.mutedText)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentIssues extends StatefulWidget {
  const _RecentIssues();

  @override
  State<_RecentIssues> createState() => _RecentIssuesState();
}

class _RecentIssuesState extends State<_RecentIssues> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final issues = MockData.issues.where((issue) {
      return issue.title.toLowerCase().contains(query) ||
          issue.module.toLowerCase().contains(query) ||
          issue.id.toLowerCase().contains(query);
    }).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent issues',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              SizedBox(
                width: Responsive.isMobile(context) ? 150 : 280,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (!mounted) return;
                    setState(() => _query = value);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search issues',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (issues.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'No issues match this query yet. Try a different keyword.',
                style: TextStyle(color: AppColors.mutedText),
              ),
            )
          else
            for (final issue in issues) _IssueRow(issue: issue),
        ],
      ),
    );
  }
}

class _IssueRow extends StatefulWidget {
  const _IssueRow({required this.issue});

  final MockIssue issue;

  @override
  State<_IssueRow> createState() => _IssueRowState();
}

class _IssueRowState extends State<_IssueRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.go('/analysis'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: _hovered ? .07 : .04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _hovered
                          ? issue.color.withValues(alpha: .36)
                          : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: issue.color.withValues(
                          alpha: _hovered ? .16 : .05,
                        ),
                        blurRadius: _hovered ? 28 : 16,
                        spreadRadius: -10,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: issue.color.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: issue.color.withValues(alpha: .18),
                              blurRadius: 18,
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.bug_report_rounded,
                          color: issue.color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issue.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${issue.id} - ${issue.module} - ${issue.time}',
                              style: const TextStyle(
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!Responsive.isMobile(context)) ...[
                        StatusBadge(label: issue.severity, color: issue.color),
                        const SizedBox(width: 10),
                        StatusBadge(
                          label: issue.status,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
