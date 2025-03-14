import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_loop/game_loop_service.dart';
import '../services/persistence/persistence_service.dart';
import '../services/game_manager.dart'; // Add import for GameManager
import 'game_provider.dart';

/// Provider zur Verwaltung von Spielservices
class ServicesProvider with ChangeNotifier {
  final GameLoopService gameLoopService = GameLoopService();
  final PersistenceService persistenceService = PersistenceService();
  GameManager? _gameManager;
  bool _initialized = false;
  bool _initializing = false;

  bool get initialized => _initialized;
  bool get initializing => _initializing;
  GameManager? get gameManager => _gameManager;

  // Initialisiere Services
  void initialize(GameProvider gameProvider) {
    if (_initialized || _initializing) return;

    print('ServicesProvider: Initializing services...');
    _initializing = true;

    try {
      // GameManager initialisieren
      _gameManager = GameManager(
        gameProvider: gameProvider,
        servicesProvider: this,
      );

      // GameLoopService mit Providern verbinden - Null sicher machen
      if (_gameManager != null) {
        gameLoopService.setProviders(gameProvider, _gameManager!);
      } else {
        print('Error: GameManager initialization failed');
      }

      // PersistenceService mit GameProvider verbinden
      persistenceService.initialize(gameProvider);

      _initialized = true;
      print('ServicesProvider: Services initialized successfully');
    } catch (e) {
      print('Error initializing services: $e');
    } finally {
      _initializing = false;
    }

    notifyListeners();
  }

  // Setzt die Spielgeschwindigkeit
  void setGameSpeed(int speed) {
    if (_initialized) {
      gameLoopService.setSpeed(speed);
      notifyListeners();
    }
  }
}
