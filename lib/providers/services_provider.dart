import 'package:flutter/material.dart';
import '../services/game_loop/game_loop_service.dart';
import '../services/persistence/persistence_service.dart';

/// Provider zur Verwaltung von Spielservices
class ServicesProvider with ChangeNotifier {
  late GameLoopService _gameLoopService;
  late PersistenceService _persistenceService;
  bool _initialized = false;

  // Getter
  GameLoopService get gameLoopService => _gameLoopService;
  PersistenceService get persistenceService => _persistenceService;
  bool get initialized => _initialized;

  // Initialisiere Services mit BuildContext
  void initialize(BuildContext context) {
    if (!_initialized) {
      _gameLoopService = GameLoopService(context);
      _persistenceService = PersistenceService(context);

      // Auto-Save aktivieren
      _persistenceService.enableAutoSave();

      _initialized = true;
    }
  }

  // Spielgeschwindigkeit ändern
  void setGameSpeed(int speed) {
    if (_initialized) {
      _gameLoopService.setSpeed(speed);
    }
  }

  // Services bereinigen
  void dispose() {
    if (_initialized) {
      _gameLoopService.stopGameLoop();
    }
    super.dispose();
  }
}
