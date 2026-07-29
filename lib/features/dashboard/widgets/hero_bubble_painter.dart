// lib/features/dashboard/widgets/hero_bubble_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

class HeroBubble extends StatefulWidget {
  final Color bubbleColor;
  final Widget child;
  final double size;

  const HeroBubble({
    Key? key,
    required this.bubbleColor,
    required this.child,
    this.size = 180.0,
  }) : super(key: key);

  @override
  State<HeroBubble> createState() => _HeroBubbleState();
}

class _HeroBubbleState extends State<HeroBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Continuous loop animation to drive liquid waves
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: HeroBubblePainter(
            animationValue: _controller.value,
            bubbleColor: widget.bubbleColor,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: widget.child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class HeroBubblePainter extends CustomPainter {
  final double animationValue;
  final Color bubbleColor;

  HeroBubblePainter({
    required this.animationValue,
    required this.bubbleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) / 2 - 12;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          bubbleColor,
          bubbleColor.withOpacity(0.8),
          bubbleColor.withOpacity(0.6),
        ],
        stops: const [0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius))
      ..style = PaintingStyle.fill;

    // Outer warm shadow
    final shadowPaint = Paint()
      ..color = bubbleColor.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(center, baseRadius + 4, shadowPaint);

    final path = Path();
    const double step = 2; // Check point every 2 degrees

    for (double i = 0; i <= 360; i += step) {
      final double angle = i * pi / 180;
      
      // Calculate dynamic radius offset using superposition of sine waves
      final double wave1 = sin(angle * 3 + animationValue * 2 * pi) * 6;
      final double wave2 = cos(angle * 5 - animationValue * 4 * pi) * 4;
      final double r = baseRadius + wave1 + wave2;

      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Inner highlight ring for 3D glass/liquid feel
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center - const Offset(6, 6), baseRadius - 10, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant HeroBubblePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.bubbleColor != bubbleColor;
  }
}
