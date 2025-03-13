import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/species/species_model.dart';
import '../providers/game_provider.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/dimensions.dart';
import '../utils/constants/species_data.dart';
import '../utils/constants/text_styles.dart';
import '../widgets/ui/species_card_widget.dart';
import 'tutorial_screen.dart';

class SpeciesSelectionScreen extends StatefulWidget {
  const SpeciesSelectionScreen({super.key});

  @override
  State<SpeciesSelectionScreen> createState() => _SpeciesSelectionScreenState();
}

class _SpeciesSelectionScreenState extends State<SpeciesSelectionScreen> {
  String? selectedSpeciesId;

  void _handleSpeciesSelect(Species species) {
    setState(() {
      selectedSpeciesId = species.id;
    });
  }

  void _startGame() {
    if (selectedSpeciesId != null) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.setSelectedSpecies(selectedSpeciesId!);
      gameProvider.setGameState('tutorial');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TutorialScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.9),
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Colony Empire',
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.s),
                const Text(
                  'Wähle deine Ameisenart und gründe eine florierende Kolonie!',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.l),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppDimensions.m,
                          mainAxisSpacing: AppDimensions.m,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: SpeciesData.all.length,
                    itemBuilder: (context, index) {
                      final species = SpeciesData.all[index];
                      return SpeciesCardWidget(
                        species: species,
                        isSelected: selectedSpeciesId == species.id,
                        onTap: () => _handleSpeciesSelect(species),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.l),
                ElevatedButton(
                  onPressed: selectedSpeciesId != null ? _startGame : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.m,
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text(
                    'Kolonie gründen',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
