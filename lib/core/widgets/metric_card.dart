import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'glass_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: .10),
                    color.withValues(alpha: .18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: .22)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: .22),
                    blurRadius: 22,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 21),
            ),
          if (icon != null) const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedText, height: 1.45),
          ),
        ],
      ),
    );
  }
}
