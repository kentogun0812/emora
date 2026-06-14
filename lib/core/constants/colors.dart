// lib/core/constants/colors.dart
import 'package:flutter/material.dart';

class EmoraColors {
  // Theme Backgrounds
  static const Color background = Color(0xFFFDFBF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color glassBackground = Color(0x0F2D2A2E);
  static const Color glassBorder = Color(0x1F2D2A2E);

  // Brand Primaries
  static const Color primary = Color(0xFFFF7A59);
  static const Color secondary = Color(0xFFFFD2C4);
  static const Color tertiary = Color(0xFF9D8DF1);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2A2E);
  static const Color textMuted = Color(0xFF7C757D);

  // Mood Colors (Represented in Hero Bubble & UI tints)
  static const Map<String, Color> moodColors = {
    'Happy': Color(0xFFFFE3A8),         // Soft Pastel Warm Yellow
    'Calm': Color(0xFFB8E0D2),          // Pastel Mint Green
    'Tired': Color(0xFFD6E4E5),         // Relaxing Light Blue/Grey
    'Sad': Color(0xFFC5D3E8),           // Soft Periwinkle Blue
    'Irritated': Color(0xFFF0A0A0),     // Pastel Soft Red
    'NeedAffection': Color(0xFFFFB7B2), // Loving Soft Pinkish Coral
    'NeedSpace': Color(0xFFE3DFFD),     // Space Soft Lavender
  };

  // Gradients for login background
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFFFD2C4), Color(0xFFFDFBF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Map<String, ThemeColors> themes = {
    'Cozy Haven': ThemeColors(
      primary: Color(0xFFFF7A59),
      secondary: Color(0xFFFFD2C4),
      background: Color(0xFFFDFBF7),
      surface: Color(0xFFFFFFFF),
      textDark: Color(0xFF2D2A2E),
      textMuted: Color(0xFF7C757D),
    ),
    'Midnight Starlight': ThemeColors(
      primary: Color(0xFF8D99AE),
      secondary: Color(0xFF2B2D42),
      background: Color(0xFF1A1B2F),
      surface: Color(0xFF24263F),
      textDark: Color(0xFFEDF2F4),
      textMuted: Color(0xFF8D99AE),
    ),
    'Lavender Dream': ThemeColors(
      primary: Color(0xFFB39DDB),
      secondary: Color(0xFFEDE7F6),
      background: Color(0xFFFAF8FF),
      surface: Color(0xFFFFFFFF),
      textDark: Color(0xFF372A3F),
      textMuted: Color(0xFF7E6B8F),
    ),
    'Forest Retreat': ThemeColors(
      primary: Color(0xFF81C784),
      secondary: Color(0xFFE8F5E9),
      background: Color(0xFFF4F7F4),
      surface: Color(0xFFFFFFFF),
      textDark: Color(0xFF2E3D30),
      textMuted: Color(0xFF6B7E6D),
    ),
  };
}

class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textDark;
  final Color textMuted;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textDark,
    required this.textMuted,
  });
}
