// lib/features/dashboard/widgets/floating_hearts.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FloatingHearts extends StatefulWidget {
  final int nudgeTrigger;
  final Widget child;

  const FloatingHearts({
    Key? key,
    required this.nudgeTrigger,
    required this.child,
  }) : super(key: key);

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_HeartParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didUpdateWidget(covariant FloatingHearts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nudgeTrigger > oldWidget.nudgeTrigger) {
      _spawnParticles();
    }
  }

  void _spawnParticles() {
    _particles.clear();
    // Spawn 8-12 heart particles
    final int count = 8 + _random.nextInt(5);
    for (int i = 0; i < count; i++) {
      _particles.add(_HeartParticle(
        startX: 0.0,
        startY: 20.0,
        // Drift left or right randomly
        targetX: -80.0 + _random.nextDouble() * 160.0,
        targetY: -180.0 - _random.nextDouble() * 100.0,
        size: 14.0 + _random.nextDouble() * 14.0,
        // Staggered delay to make launch look natural
        delay: _random.nextDouble() * 0.4,
        color: Colors.redAccent.withOpacity(0.7 + _random.nextDouble() * 0.3),
      ));
    }
    _controller.forward(from: 0.0);
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
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            widget.child,
            ..._particles.map((particle) {
              // Calculate particle progress based on animation and delay
              final progress = (_controller.value - particle.delay) / (1.0 - particle.delay);
              if (progress <= 0.0 || progress >= 1.0) {
                return const SizedBox.shrink();
              }

              // Calculate curve offset using quadratic ease-out
              final double curveVal = Curves.easeOutCubic.transform(progress);
              final double curX = particle.startX + (particle.targetX - particle.startX) * curveVal;
              final double curY = particle.startY + (particle.targetY - particle.startY) * curveVal;

              // Wave offset for wind-drift effect
              final double wave = sin(progress * pi * 3) * 12.0;

              return Positioned(
                left: (180 / 2) + curX + wave - (particle.size / 2),
                top: (180 / 2) + curY - (particle.size / 2),
                child: Opacity(
                  opacity: 1.0 - progress,
                  child: Icon(
                    Icons.favorite,
                    size: particle.size,
                    color: particle.color,
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class _HeartParticle {
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;
  final double size;
  final double delay;
  final Color color;

  _HeartParticle({
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.size,
    required this.delay,
    required this.color,
  });
}
