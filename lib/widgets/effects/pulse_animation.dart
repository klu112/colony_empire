import 'package:flutter/material.dart';

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;
  final bool active;

  const PulseAnimation({
    super.key,
    required this.child,
    required this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.active = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active && !oldWidget.active) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            if (widget.active)
              Positioned.fill(
                child: CustomPaint(
                  painter: PulsePainter(
                    color: widget.color,
                    animationValue: _animation.value,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PulsePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  PulsePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width + size.height) / 4;

    final Paint paint =
        Paint()
          ..color = color.withOpacity(0.3 * (1 - animationValue))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 + animationValue * 2.0;

    canvas.drawCircle(center, radius + (animationValue * 5), paint);
  }

  @override
  bool shouldRepaint(PulsePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
