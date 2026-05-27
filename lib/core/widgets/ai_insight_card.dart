import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'glass_card.dart';
import 'status_badge.dart';

class AIInsightCard extends StatelessWidget {
  const AIInsightCard({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.auto_awesome_rounded,
    this.color = AppColors.cyan,
    this.badge,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: color,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: .26),
                  AppColors.secondary.withValues(alpha: .16),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withValues(alpha: .24)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .20),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (badge != null) StatusBadge(label: badge!, color: color),
                  ],
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
