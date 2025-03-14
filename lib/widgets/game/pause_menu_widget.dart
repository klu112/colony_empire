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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width:
              isSmallScreen
                  ? size.width * 0.8
                  : MediaQuery.of(context).size.width * 0.3,
          constraints: BoxConstraints(maxWidth: 350),
          padding: EdgeInsets.all(isSmallScreen ? 16 : AppDimensions.l),
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
                style:
                    isSmallScreen
                        ? TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                        : AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 16 : AppDimensions.l),
              _buildButton(
                context: context,
                text: 'Fortsetzen',
                icon: Icons.play_arrow,
                onPressed: () => _resumeGame(context),
              ),
              SizedBox(height: isSmallScreen ? 8 : AppDimensions.s),
              _buildButton(
                context: context,
                text: 'Speichern',
                icon: Icons.save,
                onPressed: () => _saveGame(context),
              ),
              SizedBox(height: isSmallScreen ? 8 : AppDimensions.s),
              _buildButton(
                context: context,
                text: 'Zum Hauptmenü',
                icon: Icons.home,
                onPressed: () => _exitToMainMenu(context),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          print('Pause menu button tapped: $text');
          onPressed();
        },
        icon: Icon(icon, size: isSmallScreen ? 18 : 22),
        label: Text(text, style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : AppDimensions.m,
            vertical: isSmallScreen ? 8 : AppDimensions.s,
          ),
          minimumSize: Size(0, isSmallScreen ? 36 : 44),
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
