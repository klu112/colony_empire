import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../resources/resource_bar_widget.dart';

class ResourcesSectionWidget extends StatelessWidget {
  const ResourcesSectionWidget({super.key});
  static final Map<String, double> previousValues = {};

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final resources = gameProvider.resources;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : AppDimensions.m,
                vertical: isSmallScreen ? 4.0 : AppDimensions.s,
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Ressourcen',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : AppDimensions.m),
              child: Column(
                children: [
                  ResourceBarWidget(
                    label: 'Nahrung',
                    value: resources.food,
                    color: AppColors.food,
                    icon: '🍃',
                    key: ValueKey('food_${resources.food.toStringAsFixed(1)}'),
                  ),
                  SizedBox(height: isSmallScreen ? 8.0 : AppDimensions.m),
                  ResourceBarWidget(
                    label: 'Baumaterial',
                    value: resources.buildingMaterials,
                    color: AppColors.buildingMaterials,
                    icon: '🧱',
                  ),
                  SizedBox(height: isSmallScreen ? 8.0 : AppDimensions.m),
                  ResourceBarWidget(
                    label: 'Wasser',
                    value: resources.water,
                    color: AppColors.water,
                    icon: '💧',
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
