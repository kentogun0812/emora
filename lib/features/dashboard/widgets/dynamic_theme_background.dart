// lib/features/dashboard/widgets/dynamic_theme_background.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../settings/bloc/theme_bloc.dart';
import '../../settings/bloc/theme_state.dart';

class ThemeParticle {
  double x;
  double y;
  double size;
  double speed;
  double baseSpeed;
  double angle;
  double opacity;
  double targetOpacity;
  double rotation;
  double rotationSpeed;
  double swayOffset;
  double swaySpeed;

  ThemeParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.baseSpeed,
    required this.angle,
    required this.opacity,
    required this.targetOpacity,
    required this.rotation,
    required this.rotationSpeed,
    required this.swayOffset,
    required this.swaySpeed,
  });

  void reset(double width, double height, String themeName) {
    final random = math.Random();
    size = random.nextDouble() * 12 + 6;
    baseSpeed = random.nextDouble() * 0.8 + 0.4;
    speed = baseSpeed;
    opacity = random.nextDouble() * 0.4 + 0.1;
    targetOpacity = opacity;
    rotation = random.nextDouble() * math.pi * 2;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.02;
    swayOffset = random.nextDouble() * math.pi * 2;
    swaySpeed = random.nextDouble() * 0.02 + 0.005;

    if (themeName == 'Cozy Haven') {
      // Hearts float upwards: start at bottom
      x = random.nextDouble() * width;
      y = height + random.nextDouble() * 40;
    } else if (themeName == 'Lavender Dream') {
      // Petals fall diagonally down-right: start top or left
      if (random.nextBool()) {
        x = random.nextDouble() * width;
        y = -20;
      } else {
        x = -20;
        y = random.nextDouble() * height;
      }
    } else if (themeName == 'Forest Retreat') {
      // Leaves drift downwards: start top
      x = random.nextDouble() * width;
      y = -20;
    } else {
      // Midnight Starlight: stars twinkle in place
      x = random.nextDouble() * width;
      y = random.nextDouble() * height;
    }
  }
}

class DynamicThemeBackground extends StatefulWidget {
  final Widget child;

  const DynamicThemeBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<DynamicThemeBackground> createState() => _DynamicThemeBackgroundState();
}

class _DynamicThemeBackgroundState extends State<DynamicThemeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ThemeParticle> _particles = [];
  String _currentTheme = '';
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles(double width, double height, String themeName) {
    _particles.clear();
    for (int i = 0; i < 22; i++) {
      final p = ThemeParticle(
        x: _random.nextDouble() * width,
        y: _random.nextDouble() * height,
        size: _random.nextDouble() * 12 + 6,
        speed: 1.0,
        baseSpeed: _random.nextDouble() * 0.8 + 0.4,
        angle: 0,
        opacity: _random.nextDouble() * 0.4 + 0.1,
        targetOpacity: _random.nextDouble() * 0.4 + 0.1,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.02,
        swayOffset: _random.nextDouble() * math.pi * 2,
        swaySpeed: _random.nextDouble() * 0.02 + 0.005,
      );
      _particles.add(p);
    }
    _currentTheme = themeName;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final themeColors = state.themeColors;
        final themeName = state.themeName;

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 0 ? constraints.maxWidth : 400.0;
            final height = constraints.maxHeight > 0 ? constraints.maxHeight : 800.0;

            if (_particles.isEmpty || _currentTheme != themeName) {
              _initializeParticles(width, height, themeName);
            }

            return Stack(
              children: [
                // Animated Custom Paint Background
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(width, height),
                      painter: _ThemeBackgroundPainter(
                        particles: _particles,
                        themeName: themeName,
                        themeColors: themeColors,
                        random: _random,
                      ),
                    );
                  },
                ),
                // The actual child screen content (e.g. Glassmorphic cards)
                widget.child,
              ],
            );
          },
        );
      },
    );
  }
}

class _ThemeBackgroundPainter extends CustomPainter {
  final List<ThemeParticle> particles;
  final String themeName;
  final ThemeColors themeColors;
  final math.Random random;

  _ThemeBackgroundPainter({
    required this.particles,
    required this.themeName,
    required this.themeColors,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background color
    final backgroundPaint = Paint()..color = themeColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      // 1. Update particle state
      p.rotation += p.rotationSpeed;
      p.swayOffset += p.swaySpeed;

      if (themeName == 'Cozy Haven') {
        // Floating hearts: go upwards, sway horizontally
        p.y -= p.baseSpeed * 1.2;
        p.x += math.sin(p.swayOffset) * 0.4;
        paint.color = themeColors.primary.withOpacity(p.opacity);

        // Check bounds
        if (p.y < -p.size) {
          p.reset(size.width, size.height, themeName);
        }
      } else if (themeName == 'Lavender Dream') {
        // Lavender petals: fall diagonally down-right
        p.y += p.baseSpeed * 1.5;
        p.x += p.baseSpeed * 1.2 + math.sin(p.swayOffset) * 0.3;
        paint.color = themeColors.primary.withOpacity(p.opacity);

        // Check bounds
        if (p.y > size.height + p.size || p.x > size.width + p.size) {
          p.reset(size.width, size.height, themeName);
        }
      } else if (themeName == 'Forest Retreat') {
        // Sage leaves: drift downwards with gentle sway
        p.y += p.baseSpeed * 1.0;
        p.x += math.sin(p.swayOffset) * 0.6;
        paint.color = themeColors.primary.withOpacity(p.opacity);

        // Check bounds
        if (p.y > size.height + p.size) {
          p.reset(size.width, size.height, themeName);
        }
      } else {
        // Midnight Starlight: twinkling stars in place
        // Change target opacity randomly to simulate twinkle
        if (random.nextDouble() < 0.05) {
          p.targetOpacity = random.nextDouble() * 0.6 + 0.1;
        }
        // Smoothly interpolate opacity
        p.opacity += (p.targetOpacity - p.opacity) * 0.1;
        paint.color = Colors.white.withOpacity(p.opacity);
      }

      // 2. Draw particle shape
      final center = Offset(p.x, p.y);
      if (themeName == 'Cozy Haven') {
        _drawHeart(canvas, center, p.size, paint);
      } else if (themeName == 'Lavender Dream') {
        _drawPetal(canvas, center, p.size, p.rotation, paint);
      } else if (themeName == 'Forest Retreat') {
        _drawLeaf(canvas, center, p.size, p.rotation, paint);
      } else {
        _drawStar(canvas, center, p.size, paint);
      }
    }
  }

  // Draw Heart
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path();
    path.moveTo(center.dx, center.dy + size * 0.35);
    // Left curve
    path.cubicTo(
      center.dx - size * 0.5,
      center.dy - size * 0.15,
      center.dx - size * 0.9,
      center.dy + size * 0.4,
      center.dx,
      center.dy + size * 1.0,
    );
    // Right curve
    path.cubicTo(
      center.dx + size * 0.9,
      center.dy + size * 0.4,
      center.dx + size * 0.5,
      center.dy - size * 0.15,
      center.dx,
      center.dy + size * 0.35,
    );
    canvas.drawPath(path, paint);
  }

  // Draw Leaf
  void _drawLeaf(Canvas canvas, Offset center, double size, double rotation, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final Path path = Path();
    path.moveTo(0, -size);
    path.quadraticBezierTo(-size * 0.5, -size * 0.2, 0, size);
    path.quadraticBezierTo(size * 0.5, -size * 0.2, 0, -size);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  // Draw Petal
  void _drawPetal(Canvas canvas, Offset center, double size, double rotation, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final Path path = Path();
    path.moveTo(0, -size);
    path.quadraticBezierTo(-size * 0.4, 0, 0, size);
    path.quadraticBezierTo(size * 0.4, 0, 0, -size);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  // Draw Twinkling Sparkle Star
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final Path path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ThemeBackgroundPainter oldDelegate) => true;
}
