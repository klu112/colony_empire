import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/dimensions.dart';
import '../utils/constants/game_enums.dart';
import '../utils/constants/text_styles.dart';
import '../utils/constants/tutorial_data.dart';
import '../widgets/game/game_sidebar_widget.dart';
import '../widgets/game/nest_view_widget.dart';
import 'game/game_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < TutorialData.steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Tutorial beenden und Spiel starten
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.setGameState(GameState.playing);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTutorial() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.setGameState(GameState.playing);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Hintergrund (Game Screen)
          SafeArea(
            child: Row(
              children: const [
                // Nestansicht
                Expanded(child: NestViewWidget()),

                // Seitenleiste
                GameSidebarWidget(),
              ],
            ),
          ),

          // Abgedunkelter Hintergrund
          Container(color: Colors.black.withOpacity(0.7)),

          // Tutorial-Dialog
          Center(
            child: Container(
              width:
                  isSmallScreen
                      ? size.width * 0.9
                      : MediaQuery.of(context).size.width * 0.5,
              constraints: BoxConstraints(maxWidth: 450),
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
                    TutorialData.steps[_currentStep]['title']!,
                    style:
                        isSmallScreen
                            ? TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )
                            : AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 8 : AppDimensions.m),
                  Text(
                    TutorialData.steps[_currentStep]['content']!,
                    style:
                        isSmallScreen
                            ? TextStyle(fontSize: 14)
                            : AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : AppDimensions.l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: _previousStep,
                          child: const Text('Zurück'),
                        )
                      else
                        const SizedBox(width: 1), // Platzhalter
                      // Überspringen-Button
                      TextButton(
                        onPressed: _skipTutorial,
                        child: const Text('Überspringen'),
                      ),

                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 16,
                            vertical: isSmallScreen ? 4 : 8,
                          ),
                        ),
                        child: Text(
                          _currentStep < TutorialData.steps.length - 1
                              ? 'Weiter'
                              : 'Spiel starten',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
