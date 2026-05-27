import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../constants/app_colors.dart';

class GlassLens extends StatelessWidget {
  const GlassLens({
    super.key,
    required this.child,
    this.width = 112,
    this.height = 112,
    this.radius = 32,
  });

  final Widget child;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: width,
      height: height,
      borderRadius: radius,
      blur: 30,
      border: 1.4,
      alignment: Alignment.center,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: .18),
          AppColors.primary.withValues(alpha: .08),
          Colors.white.withValues(alpha: .04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: .42),
          AppColors.cyan.withValues(alpha: .52),
          AppColors.secondary.withValues(alpha: .36),
        ],
      ),
      child: child,
    );
  }
}
