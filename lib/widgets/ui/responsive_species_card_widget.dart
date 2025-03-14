import 'package:flutter/material.dart';
import '../../models/species/species_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

class ResponsiveSpeciesCardWidget extends StatelessWidget {
  final Species species;
  final bool isSelected;
  final VoidCallback onTap;

  const ResponsiveSpeciesCardWidget({
    super.key,
    required this.species,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Bildschirmgrößen abrufen
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    // Farben basierend auf Spezies-ID festlegen
    Color primaryColor = _getSpeciesColor(species.id);
    Color lightColor = _getLightSpeciesColor(species.id);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : AppDimensions.m),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dynamische Anpassung basierend auf verfügbarem Platz
            final bool showDetails = constraints.maxHeight > 200;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        species.name,
                        style:
                            isSmallScreen
                                ? TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                )
                                : AppTextStyles.heading3.copyWith(
                                  color: primaryColor,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: primaryColor,
                        size: isSmallScreen ? 18 : 24,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  species.scientificName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                if (showDetails) ...[
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Spezialisierung:',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            species.description,
                            style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                            maxLines: isSmallScreen ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stärken:',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            species.strengths,
                            style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                            maxLines: isSmallScreen ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Schwächen:',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            species.weaknesses,
                            style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                            maxLines: isSmallScreen ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Center(
                      child: Text(
                        'Tippe für Details',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getSpeciesColor(String id) {
    switch (id) {
      case 'atta':
        return AppColors.attaGreen;
      case 'oecophylla':
        return AppColors.oecophyllaYellow;
      case 'eciton':
        return AppColors.ecitonRed;
      case 'solenopsis':
        return AppColors.solenopsisOrange;
      default:
        return AppColors.primary;
    }
  }

  Color _getLightSpeciesColor(String id) {
    switch (id) {
      case 'atta':
        return AppColors.attaLightGreen;
      case 'oecophylla':
        return AppColors.oecophyllaLightYellow;
      case 'eciton':
        return AppColors.ecitonLightRed;
      case 'solenopsis':
        return AppColors.solenopsisLightOrange;
      default:
        return AppColors.surface;
    }
  }
}
