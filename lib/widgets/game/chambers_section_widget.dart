import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/chamber_data.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

class ChambersSectionWidget extends StatelessWidget {
  const ChambersSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
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
                  const Icon(Icons.home_outlined, size: 18),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    'Kammern bauen',
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppDimensions.s,
                    runSpacing: AppDimensions.s,
                    children: [
                      _buildChamberButton(
                        context: context,
                        type: 'nursery',
                        gameProvider: gameProvider,
                      ),
                      _buildChamberButton(
                        context: context,
                        type: 'storage',
                        gameProvider: gameProvider,
                      ),
                      _buildChamberButton(
                        context: context,
                        type: 'waste',
                        gameProvider: gameProvider,
                      ),
                      _buildChamberButton(
                        context: context,
                        type: 'defense',
                        gameProvider: gameProvider,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.s),
                  Text(
                    'Kosten: 20 Baumaterial pro Kammer',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChamberButton({
    required BuildContext context,
    required String type,
    required GameProvider gameProvider,
  }) {
    final chamberInfo = ChamberData.getTypeInfo(type);
    final bool canBuild = gameProvider.resources.buildingMaterials >= 20;

    return ElevatedButton(
      onPressed: canBuild ? () => gameProvider.addChamber(type) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.chamberColors[type],
        foregroundColor: Colors.black87,
        disabledBackgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.m,
          vertical: AppDimensions.s,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(chamberInfo['icon'] as String),
          const SizedBox(width: AppDimensions.xs),
          Text(chamberInfo['name'] as String),
        ],
      ),
    );
  }
}
