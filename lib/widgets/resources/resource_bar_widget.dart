import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';

class ResourceBarWidget extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final bool showPercentage;
  final String? icon;

  const ResourceBarWidget({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100.0,
    required this.color,
    this.showPercentage = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue * 100).clamp(0.0, 100.0);
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Text(icon!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                showPercentage
                    ? '${percentage.toStringAsFixed(1)}%'
                    : value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: isSmallScreen ? 8.0 : AppDimensions.resourceBarHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(
              isSmallScreen ? 4.0 : AppDimensions.radiusSmall,
            ),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage / 100,
            heightFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(
                  isSmallScreen ? 4.0 : AppDimensions.radiusSmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
