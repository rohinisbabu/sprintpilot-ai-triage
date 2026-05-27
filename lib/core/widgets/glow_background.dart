import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlowBackground extends StatelessWidget {
  const GlowBackground({super.key, required this.child, this.intensity = 1});

  final Widget child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(intensity: intensity, child: child);
  }
}

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child, this.intensity = 1});

  final Widget child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        const Positioned.fill(child: AnimatedGradient()),
        Positioned.fill(child: CustomPaint(painter: _AtmospherePainter())),
        const Positioned(
          top: -220,
          left: -160,
          child: _GlowBlob(size: 520, color: AppColors.primary),
        ),
        const Positioned(
          top: 70,
          right: -190,
          child: _GlowBlob(size: 560, color: AppColors.secondary),
        ),
        Positioned(
          top: size.height * .36,
          left: size.width * .18,
          child: _GlowBlob(
            size: 420,
            color: AppColors.cyan.withValues(alpha: .16 * intensity),
          ),
        ),
        Positioned(
          bottom: -260,
          left: size.width * .28,
          child: _GlowBlob(
            size: 620,
            color: AppColors.pink.withValues(alpha: .10 * intensity),
          ),
        ),
        Positioned(
          top: size.height * .18,
          left: size.width * .42,
          child: _EnergyRing(
            size: 260,
            color: AppColors.primary.withValues(alpha: .11 * intensity),
          ),
        ),
        Positioned(
          top: size.height * .12,
          right: size.width * .22,
          child: _EnergyRing(
            size: 130,
            color: AppColors.cyan.withValues(alpha: .07 * intensity),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0x30050713),
                  Color(0xE602030A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(.16, -.65),
                radius: 1.06,
                colors: [
                  Colors.white.withValues(alpha: .06),
                  AppColors.background.withValues(alpha: .18),
                  AppColors.backgroundDeep.withValues(alpha: .78),
                ],
                stops: const [.0, .42, 1],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class AnimatedGradient extends StatelessWidget {
  const AnimatedGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundVoid,
            Color(0xFF061027),
            Color(0xFF0B1020),
            Color(0xFF050614),
          ],
          stops: [.02, .32, .68, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * .38,
              spreadRadius: size * .13,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergyRing extends StatelessWidget {
  const _EnergyRing({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
          boxShadow: [
            BoxShadow(color: color, blurRadius: 38, spreadRadius: -8),
          ],
        ),
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final topLight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.28, -.72),
        radius: .78,
        colors: [
          AppColors.primary.withValues(alpha: .16),
          AppColors.secondary.withValues(alpha: .07),
          Colors.transparent,
        ],
        stops: const [0, .42, 1],
      ).createShader(rect);
    canvas.drawRect(rect, topLight);

    final consoleGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(.66, -.18),
        radius: .62,
        colors: [
          AppColors.cyan.withValues(alpha: .095),
          AppColors.primary.withValues(alpha: .045),
          Colors.transparent,
        ],
        stops: const [0, .44, 1],
      ).createShader(rect);
    canvas.drawRect(rect, consoleGlow);

    final floorGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(.12, 1.08),
        radius: .86,
        colors: [
          AppColors.secondary.withValues(alpha: .12),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, floorGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: .023)
      ..strokeWidth = 1;
    const gap = 48.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: .46)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);

    final dataPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: .052)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (double y = 24; y < size.height; y += 144) {
      canvas.drawLine(Offset(0, y), Offset(size.width * .16, y), dataPaint);
      canvas.drawLine(
        Offset(size.width * .84, y + 58),
        Offset(size.width, y + 58),
        dataPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
