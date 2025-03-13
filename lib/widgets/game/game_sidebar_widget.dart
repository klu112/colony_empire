import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/species_data.dart';
import '../../utils/constants/text_styles.dart';
import 'chambers_section_widget.dart';
import 'population_section_widget.dart';
import 'resources_section_widget.dart';
import 'tasks_section_widget.dart';

class GameSidebarWidget extends StatelessWidget {
  const GameSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Spezies-Informationen
        final species =
            gameProvider.selectedSpeciesId != null
                ? SpeciesData.getById(gameProvider.selectedSpeciesId!)
                : null;

        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(-3, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Kolonie-Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.m),
                color:
                    species != null
                        ? _getSpeciesColor(species.color)
                        : AppColors.primary,
                child: Row(
                  children: [
                    Icon(
                      Icons.pest_control_outlined,
                      color:
                          species != null
                              ? _getSpeciesColor(
                                        species.color,
                                      ).computeLuminance() >
                                      0.5
                                  ? Colors.black87
                                  : Colors.white
                              : Colors.white,
                    ),
                    const SizedBox(width: AppDimensions.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            species?.name ?? 'Deine Kolonie',
                            style: AppTextStyles.heading3.copyWith(
                              color:
                                  species != null
                                      ? _getSpeciesColor(
                                                species.color,
                                              ).computeLuminance() >
                                              0.5
                                          ? Colors.black87
                                          : Colors.white
                                      : Colors.white,
                            ),
                          ),
                          if (species != null)
                            Text(
                              species.scientificName,
                              style: AppTextStyles.caption.copyWith(
                                color:
                                    species != null
                                        ? _getSpeciesColor(
                                                  species.color,
                                                ).computeLuminance() >
                                                0.5
                                            ? Colors.black54
                                            : Colors.white70
                                        : Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollbarer Inhalt
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      // Ressourcen
                      ResourcesSectionWidget(),

                      // Population
                      PopulationSectionWidget(),

                      // Aufgabenverteilung
                      TasksSectionWidget(),

                      // Kammerbau
                      ChambersSectionWidget(),

                      SizedBox(height: AppDimensions.l),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getSpeciesColor(String colorName) {
    switch (colorName) {
      case 'green':
        return AppColors.attaGreen;
      case 'yellow':
        return AppColors.oecophyllaYellow;
      case 'red':
        return AppColors.ecitonRed;
      case 'orange':
        return AppColors.solenopsisOrange;
      default:
        return AppColors.primary;
    }
  }
}
