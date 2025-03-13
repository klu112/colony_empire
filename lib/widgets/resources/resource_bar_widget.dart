import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

class ResourceBarWidget extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final bool showPercentage;

  const ResourceBarWidget({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100.0,
    required this.color,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue * 100).clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.label),
              Text(
                showPercentage
                    ? '${percentage.toStringAsFixed(1)}%'
                    : value.toStringAsFixed(1),
                style: AppTextStyles.resourceValue,
              ),
            ],
          ),
        ),
        Container(
          height: AppDimensions.resourceBarHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage / 100,
            heightFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
