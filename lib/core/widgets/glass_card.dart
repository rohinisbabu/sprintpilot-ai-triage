import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.onTap,
    this.glowColor = AppColors.primary,
    this.hoverable = true,
    this.scaleOnHover = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color glowColor;
  final bool hoverable;
  final bool scaleOnHover;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.hoverable && _hovered;
    final radius = BorderRadius.circular(widget.borderRadius);
    final content = Container(
      transform: active ? Matrix4.translationValues(0, -7, 0) : null,
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        color: AppColors.card.withValues(alpha: active ? .48 : .38),
        borderRadius: radius,
        border: Border.all(
          color: active
              ? widget.glowColor.withValues(alpha: .62)
              : Colors.white.withValues(alpha: .14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: active ? .54 : .42),
            blurRadius: active ? 64 : 44,
            spreadRadius: -12,
            offset: Offset(0, active ? 34 : 24),
          ),
          BoxShadow(
            color: widget.glowColor.withValues(alpha: active ? .30 : .13),
            blurRadius: active ? 58 : 34,
            spreadRadius: active ? -4 : -10,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: active ? .18 : .07),
            blurRadius: active ? 80 : 42,
            spreadRadius: -20,
            offset: const Offset(-18, -10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.18,
                  colors: [
                    Colors.white.withValues(alpha: active ? .18 : .12),
                    widget.glowColor.withValues(alpha: active ? .16 : .08),
                    Colors.transparent,
                  ],
                  stops: const [0, .36, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: active ? .16 : .10),
                    Colors.transparent,
                    Colors.black.withValues(alpha: .12),
                  ],
                  stops: const [0, .24, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: active ? .10 : .06),
                ),
              ),
            ),
          ),
          Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) {
        if (widget.hoverable) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (widget.hoverable) setState(() => _hovered = false);
      },
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: widget.onTap == null
              ? content
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: radius,
                    onTap: widget.onTap,
                    child: content,
                  ),
                ),
        ),
      ),
    );
  }
}

class HoverCard extends StatelessWidget {
  const HoverCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.glowColor = AppColors.primary,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      borderRadius: borderRadius,
      glowColor: glowColor,
      onTap: onTap,
      child: child,
    );
  }
}
