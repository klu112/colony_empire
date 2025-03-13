import 'package:flutter/material.dart';
import '../../models/chamber/chamber_model.dart';
import '../../utils/constants/chamber_data.dart';
import '../../utils/constants/colors.dart';

class ChamberWidget extends StatelessWidget {
  final Chamber chamber;
  final VoidCallback? onTap;
  final bool isSelected;

  const ChamberWidget({
    super.key,
    required this.chamber,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chamberInfo = ChamberData.getTypeInfo(chamber.type);
    final color = AppColors.chamberColors[chamber.type] ?? Colors.grey;
    final borderColor = isSelected ? Colors.white : Colors.grey.shade800;
    final borderWidth = isSelected ? 3.0 : 1.0;

    return Positioned(
      left: chamber.position.x - 20.0 * chamber.size,
      top: chamber.position.y - 20.0 * chamber.size,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.0 * chamber.size,
          height: 40.0 * chamber.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Center(
            child: Text(
              chamberInfo['icon'] as String,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
