import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/services_provider.dart';
import '../utils/constants/game_enums.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    print('GameScreen: initState');

    // PostFrameCallback nutzen für sicheren Zugriff auf Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('GameScreen: PostFrameCallback');
      _checkInitialization();
    });
  }

  // Prüft, ob die Services initialisiert sind
  void _checkInitialization() {
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Sicherstellen, dass die Services initialisiert sind
    if (!servicesProvider.initialized && !servicesProvider.initializing) {
      print('Services not initialized yet. Initializing...');
      servicesProvider.initialize(gameProvider);
    }

    // Wenn GameState bereits Playing ist, starte Game Loop
    if (gameProvider.gameState == GameState.playing &&
        servicesProvider.initialized) {
      print('Game state is already Playing, starting game loop');
      servicesProvider.gameLoopService.setSpeed(gameProvider.speed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);

    // Ladeanzeige wenn Services noch nicht initialisiert sind
    if (!servicesProvider.initialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Kolonie wird initialisiert...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Rest des Builds wie bisher
    return Scaffold(
      appBar: AppBar(title: const Text('Game Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Game Content Here'),
            const SizedBox(height: 20),
            _buildGameControls(),
          ],
        ),
      ),
    );
  }

  // Spielsteuerung (Geschwindigkeit, etc.)
  Widget _buildGameControls() {
    final gameProvider = Provider.of<GameProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSpeedButton(0, gameProvider, 'Pause'),
        _buildSpeedButton(1, gameProvider, 'Normal'),
        _buildSpeedButton(2, gameProvider, 'Fast'),
      ],
    );
  }

  Widget _buildSpeedButton(int speed, GameProvider gameProvider, String label) {
    final isActive = gameProvider.speed == speed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          print('Speed button tapped: $speed');
          gameProvider.setSpeed(speed);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? Theme.of(context).colorScheme.primary : null,
          foregroundColor: isActive ? Colors.white : null,
        ),
        child: Text(label),
      ),
    );
  }
}
