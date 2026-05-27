import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_lens.dart';
import '../../core/widgets/glow_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/widgets/status_badge.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);
    final isMobile = Responsive.isMobile(context);

    return GlowBackground(
      intensity: 1.2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopNav(padding: padding)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, 34, padding, 76),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Positioned(
                          top: 120,
                          right: -120,
                          child: _SectionGlow(color: AppColors.primary),
                        ),
                        const Positioned(
                          top: 680,
                          left: -160,
                          child: _SectionGlow(color: AppColors.secondary),
                        ),
                        Column(
                          children: [
                            _HeroSection(isMobile: isMobile),
                            const SizedBox(height: 42),
                            _StatsGrid(isMobile: isMobile),
                            const SizedBox(height: 18),
                            const _AutomationImpact(),
                            const SizedBox(height: 92),
                            _HowItWorks(isMobile: isMobile),
                            const SizedBox(height: 76),
                            _FeatureGrid(isMobile: isMobile),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 18, padding, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: 24,
            child: Row(
              children: [
                const _BrandMark(),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'SprintPilot AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                const Spacer(),
                if (!Responsive.isMobile(context)) ...[
                  _NavText('Workflow', onTap: () => context.go('/upload')),
                  _NavText('Analysis', onTap: () => context.go('/analysis')),
                  _NavText(
                    'Release Notes',
                    onTap: () => context.go('/release-notes'),
                  ),
                  const SizedBox(width: 14),
                ],
                GradientButton(
                  label: 'Launch App',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.go('/dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        const StatusBadge(
          label: 'AI release ops command center',
          color: AppColors.cyan,
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 24),
        _GradientHeadline(
          text: 'AI-Powered Bug Triage & Engineering Workflow Assistant',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 20),
        Text(
          'Convert messy QA reports into actionable engineering tickets, sprint insights, and release-ready summaries in seconds using AI.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 19,
            height: 1.48,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 14,
          runSpacing: 14,
          children: [
            GradientButton(
              label: 'Analyze QA Report',
              icon: Icons.upload_file_rounded,
              onPressed: () => context.go('/upload'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.dashboard_customize_rounded),
              label: const Text('View AI Console'),
            ),
          ],
        ),
      ],
    );

    final preview = const Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(top: -54, right: -22, child: _HeroOrb()),
        Positioned(left: -18, bottom: 34, child: _DataFlowRibbon()),
        _DashboardPreview(),
      ],
    );

    if (isMobile) {
      return Column(children: [copy, const SizedBox(height: 38), preview]);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 46),
      child: Row(
        children: [
          Expanded(flex: 10, child: copy),
          const SizedBox(width: 50),
          Expanded(flex: 9, child: preview),
        ],
      ),
    );
  }
}

class _GradientHeadline extends StatelessWidget {
  const _GradientHeadline({required this.text, required this.textAlign});

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xFFEAF1FF), AppColors.cyan],
        stops: [.08, .62, 1],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: Responsive.isMobile(context) ? 44 : 62,
          height: .94,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HeroOrb extends StatelessWidget {
  const _HeroOrb();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GlassLens(
        width: 128,
        height: 128,
        radius: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.heroGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .52),
                    blurRadius: 48,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomationImpact extends StatelessWidget {
  const _AutomationImpact();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 22,
      glowColor: AppColors.success,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_graph_rounded, color: AppColors.success),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              '22-45 hrs sprint overhead reduced to 5-8 hrs with AI automation.',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusBadge(
                label: 'Live Analysis',
                color: AppColors.success,
                icon: Icons.radar_rounded,
              ),
              const SizedBox(width: 12),
              const _WaveformIndicator(),
              const Spacer(),
              Icon(
                Icons.more_horiz_rounded,
                color: Colors.white.withValues(alpha: .62),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xD80F1427),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .18),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .12),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: _ScanBeam()),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withValues(alpha: .22),
                                blurRadius: 26,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bug_report_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BUG-4281 generated',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 7),
                              Text(
                                'Payments Service - Critical - 92% confidence',
                                style: TextStyle(color: AppColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const ShimmerBox(height: 14),
                    const SizedBox(height: 10),
                    const ShimmerBox(height: 14, width: 280),
                    const SizedBox(height: 20),
                    _PreviewRow(
                      label: 'Root cause',
                      value: 'Null callback guard',
                    ),
                    _PreviewRow(
                      label: 'Duplicate match',
                      value: '3 similar reports merged',
                    ),
                    _PreviewRow(label: 'Release note', value: 'Draft ready'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _MiniChart(color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _MiniChart(color: AppColors.secondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanBeam extends StatelessWidget {
  const _ScanBeam();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.cyan.withValues(alpha: .12),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.mutedText)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          7,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: FractionallySizedBox(
                heightFactor: [.34, .52, .42, .74, .58, .86, .68][index],
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, AppColors.cyan.withValues(alpha: .72)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: .22),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final cards = const [
      MetricCard(
        value: '80%',
        label: 'Faster Triage',
        icon: Icons.speed_rounded,
      ),
      MetricCard(
        value: '30s',
        label: 'Ticket Creation',
        icon: Icons.timer_rounded,
        color: AppColors.secondary,
      ),
      MetricCard(
        value: '50%',
        label: 'Fewer Duplicate Reports',
        icon: Icons.merge_type_rounded,
      ),
      MetricCard(
        value: '95%',
        label: 'AI Accuracy',
        icon: Icons.verified_rounded,
        color: AppColors.success,
      ),
    ];
    return GridView.count(
      crossAxisCount: isMobile ? 1 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 2.8 : 1.22,
      children: cards,
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        'Upload evidence',
        'Drop QA reports, screenshots, and logs into one AI intake flow.',
        Icons.cloud_upload_outlined,
      ),
      (
        'AI extracts context',
        'SprintPilot identifies severity, root cause, module, and duplicates.',
        Icons.psychology_alt_outlined,
      ),
      (
        'Ship clean outputs',
        'Generate Jira-style tickets and executive release notes instantly.',
        Icons.rocket_launch_outlined,
      ),
    ];
    return Column(
      children: [
        const SectionHeader(
          eyebrow: 'How it works',
          title: 'From messy reports to engineering-ready workflow',
          subtitle:
              'Designed for QA, support, and engineering teams that need signal without manual triage overhead.',
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: isMobile ? 1 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: isMobile ? 2.25 : 1.16,
          children: [
            for (final step in steps)
              GlassCard(
                glowColor: step.$3 == Icons.psychology_alt_outlined
                    ? AppColors.secondary
                    : AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassLens(
                      width: 54,
                      height: 54,
                      radius: 18,
                      child: Icon(step.$3, color: AppColors.cyan, size: 28),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      step.$1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      step.$2,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        'Duplicate detection',
        'Cluster noisy QA submissions into one actionable thread.',
      ),
      (
        'Root-cause summaries',
        'Turn logs and screenshots into concise technical diagnosis.',
      ),
      (
        'Release note drafting',
        'Translate ticket resolution into polished stakeholder updates.',
      ),
      (
        'Integration ready',
        'Structured JSON exports for Jira, Linear, Slack, and internal tools.',
      ),
    ];
    return Column(
      children: [
        const SectionHeader(
          eyebrow: 'Platform',
          title: 'Built for production engineering teams',
          subtitle:
              'A focused AI layer that speeds handoffs while preserving the rigor senior engineers expect.',
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: isMobile ? 1 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: isMobile ? 2.65 : 2.25,
          children: [
            for (final feature in features)
              GlassCard(
                glowColor: AppColors.cyan,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .24),
                            blurRadius: 26,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_fix_high_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            feature.$1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feature.$2,
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
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionGlow extends StatelessWidget {
  const _SectionGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .16),
              blurRadius: 120,
              spreadRadius: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _DataFlowRibbon extends StatelessWidget {
  const _DataFlowRibbon();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 18,
        glowColor: AppColors.cyan,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 4; i++) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i.isEven ? AppColors.cyan : AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (i.isEven ? AppColors.cyan : AppColors.secondary)
                          .withValues(alpha: .45),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
              if (i != 3)
                Container(
                  width: 24,
                  height: 1,
                  color: Colors.white.withValues(alpha: .18),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaveformIndicator extends StatelessWidget {
  const _WaveformIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          8,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                height: const <double>[7, 13, 9, 18, 11, 16, 8, 12][index],
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: .68),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: .26),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .42),
            blurRadius: 24,
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white),
    );
  }
}

class _NavText extends StatefulWidget {
  const _NavText(this.label, {required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavText> createState() => _NavTextState();
}

class _NavTextState extends State<_NavText> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Transform.scale(
          scale: _hovered ? 1.04 : 1.0,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _hovered ? .08 : 0),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: _hovered ? .13 : 0),
                ),
                boxShadow: [
                  if (_hovered)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .16),
                      blurRadius: 18,
                      spreadRadius: -8,
                    ),
                ],
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: _hovered ? AppColors.text : AppColors.mutedText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
