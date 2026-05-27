import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFF0B1020);
  static const backgroundDeep = Color(0xFF050713);
  static const backgroundVoid = Color(0xFF02030A);
  static const backgroundInk = Color(0xFF080B18);
  static const card = Color(0xFF151A2E);
  static const primary = Color(0xFF5B8CFF);
  static const secondary = Color(0xFF8B5CF6);
  static const cyan = Color(0xFF38D5FF);
  static const pink = Color(0xFFFF5CF4);
  static const critical = Color(0xFFFF4D4F);
  static const success = Color(0xFF52C41A);
  static const warning = Color(0xFFF5A524);
  static const text = Color(0xFFF7F9FF);
  static const mutedText = Color(0xFFA6B0CF);
  static const border = Color(0x14FFFFFF);
  static const field = Color(0x1AFFFFFF);

  static const heroGradient = LinearGradient(
    colors: [cyan, primary, secondary, pink],
    stops: [.02, .34, .72, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glassGradient = LinearGradient(
    colors: [
      Color(0x42FFFFFF),
      Color(0x16FFFFFF),
      Color(0x0A5B8CFF),
      Color(0x1A000000),
    ],
    stops: [.0, .34, .68, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [backgroundDeep, backgroundInk, background],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
