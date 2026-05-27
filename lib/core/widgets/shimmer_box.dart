import 'package:flutter/material.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 14,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
