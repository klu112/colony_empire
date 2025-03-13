import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';
import '../resources/resource_bar_widget.dart';

class ResourcesSectionWidget extends StatelessWidget {
  const ResourcesSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final resources = gameProvider.resources;

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
                  const Icon(Icons.inventory_2_outlined, size: 18),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    'Ressourcen',
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
                  ResourceBarWidget(
                    label: 'Nahrung',
                    value: resources.food,
                    color: AppColors.food,
                  ),
                  const SizedBox(height: AppDimensions.m),
                  ResourceBarWidget(
                    label: 'Baumaterial',
                    value: resources.buildingMaterials,
                    color: AppColors.buildingMaterials,
                  ),
                  const SizedBox(height: AppDimensions.m),
                  ResourceBarWidget(
                    label: 'Wasser',
                    value: resources.water,
                    color: AppColors.water,
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
