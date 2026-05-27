import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return GlowButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      expanded: expanded,
    );
  }
}

class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          scale: _pressed ? .985 : 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: .20)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: _hovered ? .42 : .24,
                  ),
                  blurRadius: _hovered ? 36 : 22,
                  spreadRadius: _hovered ? 1 : -2,
                  offset: Offset(0, _hovered ? 16 : 10),
                ),
                BoxShadow(
                  color: AppColors.secondary.withValues(
                    alpha: _hovered ? .32 : .14,
                  ),
                  blurRadius: _hovered ? 58 : 34,
                  spreadRadius: -8,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.onPressed,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: .30),
                              Colors.white.withValues(alpha: .08),
                              Colors.transparent,
                            ],
                            stops: const [0, .32, 1],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(
                                  alpha: _hovered ? .22 : .10,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [.22, .5, .78],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: widget.expanded
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 19),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return widget.expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
