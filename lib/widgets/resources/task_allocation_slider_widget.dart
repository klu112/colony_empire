import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';

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
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    taskName,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '$value%',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: isSmallScreen ? 4.0 : 6.0,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isSmallScreen ? 6.0 : 8.0,
            ),
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
