import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_lens.dart';
import '../../core/widgets/glow_background.dart';
import '../../services/mock_data.dart';
import '../../services/issue_repository.dart';
import '../../services/triage_controller.dart';

class AiProcessingPage extends ConsumerStatefulWidget {
  const AiProcessingPage({super.key});

  @override
  ConsumerState<AiProcessingPage> createState() => _AiProcessingPageState();
}

class _AiProcessingPageState extends ConsumerState<AiProcessingPage> {
  Future<void>? _analysisTask;

  @override
  void initState() {
    super.initState();
    _analysisTask = _runMockAnalysis();
  }

  Future<void> _runMockAnalysis() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    final repository = ref.read(issueRepositoryProvider.notifier);
    final issue = repository.activeIssue;
    if (issue == null) {
      if (mounted) context.go('/upload');
      return;
    }

    repository.markAnalyzing(issue.id);
    try {
      final analysis = await ref
          .read(triageControllerProvider.notifier)
          .analyzeIssue(issue);
      if (!mounted) return;
      repository.saveAnalysis(issue.id, analysis);
      context.go('/analysis');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.card.withValues(alpha: .94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: const Text(
            'AI analysis failed. Please retry.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      context.go('/upload');
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return GlowBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(child: _ParticleField()),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: GlassCard(
                    padding: const EdgeInsets.all(34),
                    borderRadius: 32,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _AiOrb(),
                        const SizedBox(height: 30),
                        Text(
                          'SprintPilot is reasoning through the evidence',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Parsing screenshots, stack traces, product context, and duplicate patterns.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.mutedText,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        FutureBuilder<void>(
                          future: _analysisTask,
                          builder: (context, snapshot) {
                            return const _ProcessingProgress();
                          },
                        ),
                        const SizedBox(height: 18),
                        for (
                          var i = 0;
                          i < MockData.processingSteps.length;
                          i++
                        )
                          _ProcessingStep(
                            label: MockData.processingSteps[i],
                            index: i,
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

class _ProcessingProgress extends StatelessWidget {
  const _ProcessingProgress();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 8,
        backgroundColor: Colors.white.withValues(alpha: .08),
        valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
      ),
    );
  }
}

class _ParticleField extends StatelessWidget {
  const _ParticleField();

  @override
  Widget build(BuildContext context) {
    final points = const [
      Alignment(-.78, -.62),
      Alignment(.74, -.48),
      Alignment(-.58, .28),
      Alignment(.62, .48),
      Alignment(.12, -.82),
      Alignment(-.14, .76),
    ];
    return Stack(
      children: [
        for (var i = 0; i < points.length; i++)
          Align(
            alignment: points[i],
            child: Container(
              width: 7 + i.toDouble(),
              height: 7 + i.toDouble(),
              decoration: BoxDecoration(
                color: i.isEven ? AppColors.cyan : AppColors.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (i.isEven ? AppColors.cyan : AppColors.secondary)
                        .withValues(alpha: .55),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AiOrb extends StatelessWidget {
  const _AiOrb();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final size in [276.0, 236.0, 196.0])
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cyan.withValues(alpha: .12)),
            ),
          ),
        Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .34),
                blurRadius: 70,
                spreadRadius: 12,
              ),
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: .24),
                blurRadius: 120,
                spreadRadius: 22,
              ),
            ],
          ),
        ),
        GlassLens(
          width: 160,
          height: 160,
          radius: 80,
          child: Container(
            width: 126,
            height: 126,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.heroGradient,
            ),
          ),
        ),
        SizedBox(
          width: 110,
          height: 110,
          child: Lottie.network(
            'https://assets2.lottiefiles.com/packages/lf20_puciaact.json',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProcessingStep extends StatelessWidget {
  const _ProcessingStep({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .28),
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: LinearProgressIndicator(
              minHeight: 5,
              borderRadius: BorderRadius.circular(999),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              backgroundColor: Colors.white.withValues(alpha: .08),
            ),
          ),
        ],
      ),
    );
  }
}
