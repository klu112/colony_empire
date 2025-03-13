import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
// Füge dart:math Import hinzu
import 'dart:math';

class NestBackgroundWidget extends StatelessWidget {
  const NestBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: NestBackgroundPainter(), child: Container());
  }
}

class NestBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Erde/Untergrundhintergrund
    final Paint backgroundPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface.withOpacity(0.7),
              AppColors.tunnel.withOpacity(0.3),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Zufällige Erdpartikel zeichnen
    final Random random = Random(42); // Konstanter Seed für gleiche Muster
    final Paint particlePaint =
        Paint()..color = AppColors.tunnel.withOpacity(0.2);

    for (int i = 0; i < 100; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius = random.nextDouble() * 3 + 1;

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Horizontale Erdschichten
    final Paint layerPaint =
        Paint()
          ..color = AppColors.tunnel.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
      final double y = size.height * (0.1 + i * 0.09);
      final Path layerPath = Path();

      layerPath.moveTo(0, y);

      // Wellige Linie erzeugen
      for (double x = 0; x < size.width; x += 10) {
        final double waveOffset =
            sin(x * 0.05) * 5 + cos(x * 0.02) * 3 + sin(y * 0.01) * 4;
        layerPath.lineTo(x, y + waveOffset);
      }

      canvas.drawPath(layerPath, layerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
