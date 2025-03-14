import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/services_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/game_enums.dart';
import '../../utils/constants/text_styles.dart';
import '../../screens/species_selection.dart';
import '../../screens/help_screen.dart';

class PauseMenuWidget extends StatelessWidget {
  final VoidCallback? onResume;

  const PauseMenuWidget({super.key, this.onResume});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          padding: const EdgeInsets.all(AppDimensions.l),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Spiel pausiert',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.l),
              _buildButton(
                context: context,
                text: 'Fortsetzen',
                icon: Icons.play_arrow,
                onPressed: () => _resumeGame(context),
              ),
              const SizedBox(height: AppDimensions.m),
              _buildButton(
                context: context,
                text: 'Speichern',
                icon: Icons.save,
                onPressed: () => _saveGame(context),
              ),
              const SizedBox(height: AppDimensions.m),
              _buildButton(
                context: context,
                text: 'Zurück zum Hauptmenü',
                icon: Icons.home,
                onPressed: () => _exitToMainMenu(context),
              ),
              _buildButton(
                context: context,
                text: 'Spielhilfe',
                icon: Icons.help_outline,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.l,
            vertical: AppDimensions.m,
          ),
        ),
      ),
    );
  }

  void _resumeGame(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );

    // Spiel fortsetzen
    gameProvider.setGameState(GameState.playing);
    servicesProvider.setGameSpeed(1);

    // onResume-Callback aufrufen, falls vorhanden
    if (onResume != null) {
      onResume!();
    }
  }

  Future<void> _saveGame(BuildContext context) async {
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );

    final success = await servicesProvider.persistenceService.saveGame();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Spiel erfolgreich gespeichert'
                : 'Fehler beim Speichern des Spiels',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _exitToMainMenu(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Zum Hauptmenü zurückkehren?'),
            content: const Text(
              'Möchtest du zum Hauptmenü zurückkehren? '
              'Ungespeicherte Fortschritte gehen verloren.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SpeciesSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Zum Hauptmenü'),
              ),
            ],
          ),
    );
  }
}
