import 'package:flutter/material.dart';
import '../../models/species/species_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

class SpeciesCardWidget extends StatelessWidget {
  final Species species;
  final bool isSelected;
  final VoidCallback onTap;

  const SpeciesCardWidget({
    super.key,
    required this.species,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Farbe basierend auf Spezies-ID festlegen
    Color primaryColor;
    Color lightColor;

    switch (species.id) {
      case 'atta':
        primaryColor = AppColors.attaGreen;
        lightColor = AppColors.attaLightGreen;
        break;
      case 'oecophylla':
        primaryColor = AppColors.oecophyllaYellow;
        lightColor = AppColors.oecophyllaLightYellow;
        break;
      case 'eciton':
        primaryColor = AppColors.ecitonRed;
        lightColor = AppColors.ecitonLightRed;
        break;
      case 'solenopsis':
        primaryColor = AppColors.solenopsisOrange;
        lightColor = AppColors.solenopsisLightOrange;
        break;
      default:
        primaryColor = AppColors.primary;
        lightColor = AppColors.surface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.m),
        decoration: BoxDecoration(
          color: isSelected ? lightColor : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    species.name,
                    style: AppTextStyles.heading3.copyWith(color: primaryColor),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: primaryColor, size: 24),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              species.scientificName,
              style: AppTextStyles.caption.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppDimensions.s),
            Text(species.description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stärken:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(species.strengths, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  'Schwächen:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(species.weaknesses, style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
