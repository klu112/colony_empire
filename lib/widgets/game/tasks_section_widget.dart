import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';
import '../resources/task_allocation_slider_widget.dart';

class TasksSectionWidget extends StatelessWidget {
  const TasksSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final taskAllocation = gameProvider.taskAllocation;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.m,
                vertical: AppDimensions.s,
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_outlined, size: 18),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    'Aufgabenverteilung',
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.m),
              child: Column(
                children: [
                  TaskAllocationSliderWidget(
                    taskName: 'Nahrungssuche',
                    icon: '🍃',
                    value: taskAllocation.foraging,
                    color: AppColors.foraging,
                    onChanged:
                        (value) => gameProvider.updateTaskAllocation(
                          'foraging',
                          value,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.s),
                  TaskAllocationSliderWidget(
                    taskName: 'Nestbau',
                    icon: '🏗️',
                    value: taskAllocation.building,
                    color: AppColors.building,
                    onChanged:
                        (value) => gameProvider.updateTaskAllocation(
                          'building',
                          value,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.s),
                  TaskAllocationSliderWidget(
                    taskName: 'Brutpflege',
                    icon: '👶',
                    value: taskAllocation.caregiving,
                    color: AppColors.caregiving,
                    onChanged:
                        (value) => gameProvider.updateTaskAllocation(
                          'caregiving',
                          value,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.s),
                  TaskAllocationSliderWidget(
                    taskName: 'Verteidigung',
                    icon: '🛡️',
                    value: taskAllocation.defense,
                    color: AppColors.defense,
                    onChanged:
                        (value) =>
                            gameProvider.updateTaskAllocation('defense', value),
                  ),
                  const SizedBox(height: AppDimensions.s),
                  TaskAllocationSliderWidget(
                    taskName: 'Erkundung',
                    icon: '🔍',
                    value: taskAllocation.exploration,
                    color: AppColors.exploration,
                    onChanged:
                        (value) => gameProvider.updateTaskAllocation(
                          'exploration',
                          value,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
