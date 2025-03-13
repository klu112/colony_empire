import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants/text_styles.dart';
import '../utils/constants/tutorial_data.dart';
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
      gameProvider.setGameState('playing');

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

  @override
  Widget build(BuildContext context) {
    // Dies ist nur ein Platzhalter und wird später mit dem tatsächlichen Spiel-Screen ersetzt
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Stack(
        children: [
          // Hintergrund (später Game Screen)
          const Center(
            child: Text(
              'Hier wird später der Spielbildschirm angezeigt',
              style: TextStyle(color: Colors.white),
            ),
          ),

          // Tutorial-Dialog
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    TutorialData.steps[_currentStep]['content']!,
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        ElevatedButton(
                          onPressed: _previousStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text('Zurück'),
                        )
                      else
                        const SizedBox(),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: Text(
                          _currentStep < TutorialData.steps.length - 1
                              ? 'Weiter'
                              : 'Spiel starten',
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
