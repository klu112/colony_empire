import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_loop/game_loop_service.dart';
import '../services/persistence/persistence_service.dart';
import '../services/game_manager.dart'; // Add import for GameManager
import 'game_provider.dart';

/// Provider zur Verwaltung von Spielservices
class ServicesProvider with ChangeNotifier {
  GameLoopService? _gameLoopService;
  PersistenceService? _persistenceService;
  GameManager? _gameManager; // Add GameManager
  GameProvider? _gameProvider;
  bool _initialized = false;
  bool _initializing = false;

  // Getter
  GameLoopService get gameLoopService {
    if (!_initialized) {
      throw StateError('ServicesProvider wurde noch nicht initialisiert');
    }
    return _gameLoopService!;
  }

  PersistenceService get persistenceService {
    if (!_initialized) {
      throw StateError('ServicesProvider wurde noch nicht initialisiert');
    }
    return _persistenceService!;
  }

  GameManager get gameManager {
    if (!_initialized) {
      throw StateError('ServicesProvider wurde noch nicht initialisiert');
    }
    return _gameManager!;
  }

  bool get initialized => _initialized;
  bool get initializing => _initializing;

  // Initialisiere Services
  Future<void> initialize(
    GameProvider gameProvider, [
    Size screenSize = const Size(800, 600),
  ]) async {
    if (_initialized || _initializing) return;

    print('Initializing ServicesProvider...');
    _initializing = true;

    try {
      _gameProvider = gameProvider;

      // GameManager initialisieren
      _gameManager = GameManager(
        gameProvider: gameProvider,
        servicesProvider: this,
      );
      _gameManager!.initialize(screenSize: screenSize);

      // Services initialisieren ohne Context
      _gameLoopService = GameLoopService();
      // Verwende die neue setProviders Methode anstelle von setGameProvider
      _gameLoopService!.setProviders(gameProvider, _gameManager!);

      _persistenceService = PersistenceService();
      _persistenceService!.setGameProvider(gameProvider);

      // Auto-Save aktivieren
      _persistenceService?.enableAutoSave();

      _initialized = true;
      _initializing = false;
      print('ServicesProvider successfully initialized');
      notifyListeners();
    } catch (e) {
      print('Error initializing ServicesProvider: $e');
      _initializing = false;
      throw e;
    }
  }

  // Spielgeschwindigkeit ändern
  void setGameSpeed(int speed) {
    if (_initialized) {
      print("ServicesProvider: Setting game speed to $speed");
      _gameLoopService?.setSpeed(speed);
    } else {
      print("Warning: Trying to set game speed before initialization");
    }
  }

  // Starte den Game Loop manuell
  void startGameLoop() {
    if (_initialized) {
      _gameLoopService?.startGameLoop();
    } else {
      print("Warning: Trying to start game loop before initialization");
    }
  }

  // Stoppe den Game Loop manuell
  void stopGameLoop() {
    if (_initialized) {
      _gameLoopService?.stopGameLoop();
    }
  }

  // Services bereinigen
  @override
  void dispose() {
    if (_initialized) {
      _gameLoopService?.stopGameLoop();
    }
    super.dispose();
  }
}
