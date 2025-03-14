import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import 'dart:math';

class ChamberBuildAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onComplete;

  const ChamberBuildAnimation({
    super.key,
    required this.child,
    required this.onComplete,
  });

  @override
  State<ChamberBuildAnimation> createState() => _ChamberBuildAnimationState();
}

class _ChamberBuildAnimationState extends State<ChamberBuildAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward().then((_) => widget.onComplete());
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                widget.child,
                if (_controller.value < 0.8)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BuildPainter(progress: _controller.value),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BuildPainter extends CustomPainter {
  final double progress;

  BuildPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Baustaubpartikel
    final random = Random();
    final particlePaint = Paint()..color = AppColors.buildingMaterials;

    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radius * 1.5;
      final particleSize = random.nextDouble() * 3 + 1;
      final particleOpacity = random.nextDouble() * 0.7 + 0.3;

      final particleOffset =
          center +
          Offset(
            cos(angle) * distance * (1 - progress),
            sin(angle) * distance * (1 - progress),
          );

      particlePaint.color = AppColors.buildingMaterials.withOpacity(
        particleOpacity * (1 - progress),
      );

      canvas.drawCircle(particleOffset, particleSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(BuildPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
