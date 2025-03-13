import 'package:flutter/material.dart';
import '../../models/chamber/chamber_model.dart';
import '../../models/chamber/tunnel_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';

class TunnelWidget extends StatelessWidget {
  final Tunnel tunnel;
  final List<Chamber> chambers;

  const TunnelWidget({super.key, required this.tunnel, required this.chambers});

  @override
  Widget build(BuildContext context) {
    final fromChamber = chambers.firstWhere((c) => c.id == tunnel.from);
    final toChamber = chambers.firstWhere((c) => c.id == tunnel.to);

    final left =
        (fromChamber.position.x < toChamber.position.x)
            ? fromChamber.position.x
            : toChamber.position.x;
    final top =
        (fromChamber.position.y < toChamber.position.y)
            ? fromChamber.position.y
            : toChamber.position.y;

    final width = (fromChamber.position.x - toChamber.position.x).abs();
    final height = (fromChamber.position.y - toChamber.position.y).abs();

    // Wenn Tunnel horizontal oder vertikal ist, stelle sicher, dass eine Mindestbreite vorhanden ist
    final adjustedWidth = width > 0 ? width : AppDimensions.tunnelWidth;
    final adjustedHeight = height > 0 ? height : AppDimensions.tunnelWidth;

    return Positioned(
      left: left,
      top: top,
      width: adjustedWidth,
      height: adjustedHeight,
      child: CustomPaint(
        painter: TunnelPainter(
          start: fromChamber.position - Offset(left, top),
          end: toChamber.position - Offset(left, top),
        ),
      ),
    );
  }
}

class TunnelPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  TunnelPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.tunnel
          ..strokeWidth = AppDimensions.tunnelWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
