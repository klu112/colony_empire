import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

class PopulationSectionWidget extends StatelessWidget {
  const PopulationSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final population = gameProvider.resources.population;
        final totalPopulation = population.values.fold(
          0,
          (sum, count) => sum + count,
        );

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
                  const Icon(Icons.people_outline, size: 18),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    'Population',
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
                  _buildPopulationRow(
                    'Königin',
                    population['queen'] ?? 0,
                    '👑',
                  ),
                  _buildPopulationRow(
                    'Arbeiterinnen',
                    population['workers'] ?? 0,
                    '🐜',
                  ),
                  _buildPopulationRow(
                    'Soldaten',
                    population['soldiers'] ?? 0,
                    '🛡️',
                  ),
                  _buildPopulationRow(
                    'Kundschafter',
                    population['scouts'] ?? 0,
                    '🔍',
                  ),
                  _buildPopulationRow(
                    'Larven',
                    population['larvae'] ?? 0,
                    '🥚',
                  ),
                  _buildPopulationRow('Eier', population['eggs'] ?? 0, '⚪'),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gesamt:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        totalPopulation.toString(),
                        style: AppTextStyles.resourceValue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopulationRow(String label, int value, String icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppDimensions.xs),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(value.toString(), style: AppTextStyles.resourceValue),
        ],
      ),
    );
  }
}
