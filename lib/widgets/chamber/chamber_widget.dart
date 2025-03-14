import 'package:flutter/material.dart';
import '../../models/chamber/chamber_model.dart';
import '../../utils/constants/chamber_data.dart';
import '../../utils/constants/colors.dart';
import '../effects/pulse_animation.dart';

class ChamberWidget extends StatelessWidget {
  final Chamber chamber;
  final VoidCallback? onTap;
  final bool isSelected;
  final double scaleFactor;
  final bool isBuilding;

  const ChamberWidget({
    super.key,
    required this.chamber,
    this.onTap,
    this.isSelected = false,
    this.scaleFactor = 1.0,
    this.isBuilding = false,
  });

  @override
  Widget build(BuildContext context) {
    final chamberInfo = ChamberData.getTypeInfo(chamber.type);
    final color = AppColors.chamberColors[chamber.type] ?? Colors.grey;
    final borderColor = isSelected ? Colors.white : Colors.grey.shade800;
    final borderWidth = isSelected ? 3.0 : 1.0;

    // Skalierte Größe basierend auf Bildschirmgröße
    final size = 40.0 * chamber.size * scaleFactor;

    return Positioned(
      left: chamber.position.x - size / 2,
      top: chamber.position.y - size / 2,
      child: GestureDetector(
        onTap: onTap,
        child: PulseAnimation(
          color: color,
          active: isSelected,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                chamberInfo['icon'] as String,
                style: TextStyle(fontSize: 16 * scaleFactor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
