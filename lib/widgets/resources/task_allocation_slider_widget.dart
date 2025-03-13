import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/text_styles.dart';

class TaskAllocationSliderWidget extends StatelessWidget {
  final String taskName;
  final String icon;
  final int value;
  final Color color;
  final Function(int) onChanged;

  const TaskAllocationSliderWidget({
    super.key,
    required this.taskName,
    required this.icon,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                  Text(icon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(taskName, style: AppTextStyles.label),
                ],
              ),
              Text('$value%', style: AppTextStyles.resourceValue),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 95,
            divisions: 19,
            onChanged: (newValue) {
              onChanged(newValue.toInt());
            },
          ),
        ),
      ],
    );
  }
}
