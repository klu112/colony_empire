import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/species/species_model.dart';
import '../providers/game_provider.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/dimensions.dart';
import '../utils/constants/game_enums.dart';
import '../utils/constants/species_data.dart';
import '../utils/constants/text_styles.dart';
import '../widgets/ui/species_card_widget.dart';
import 'tutorial_screen.dart';
import '../providers/services_provider.dart';
import 'game/game_screen.dart';

class SpeciesSelectionScreen extends StatefulWidget {
  const SpeciesSelectionScreen({super.key});

  @override
  State<SpeciesSelectionScreen> createState() => _SpeciesSelectionScreenState();
}

class _SpeciesSelectionScreenState extends State<SpeciesSelectionScreen> {
  bool _hasSavedGame = false;
  String? selectedSpeciesId;

  @override
  void initState() {
    super.initState();

    // Prüfe, ob ein Spielstand vorhanden ist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForSavedGame();
    });
  }

  void _handleSpeciesSelect(Species species) {
    setState(() {
      selectedSpeciesId = species.id;
    });
  }

  void _startGame() {
    if (selectedSpeciesId != null) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.setSelectedSpecies(selectedSpeciesId!);
      gameProvider.setGameState(GameState.tutorial);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TutorialScreen()),
      );
    }
  }

  Future<void> _checkForSavedGame() async {
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );

    // Stelle sicher, dass Services initialisiert sind
    if (!servicesProvider.initialized) {
      servicesProvider.initialize(context);
    }

    final hasSave = await servicesProvider.persistenceService.hasSavedGame();
    // Aktualisiere UI-Zustand, falls ein Spielstand vorhanden ist
    setState(() {
      _hasSavedGame = hasSave;
    });
  }

  Future<void> _loadGame() async {
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );
    final success = await servicesProvider.persistenceService.loadGame();

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    } else {
      // Zeige Fehlermeldung
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Laden des Spielstands'),
          backgroundColor: Colors.red,
        ),
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
                if (_hasSavedGame) ...[
                  const SizedBox(height: AppDimensions.m),
                  ElevatedButton.icon(
                    onPressed: _loadGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Spiel fortsetzen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.m,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.m),
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
