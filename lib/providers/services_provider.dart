import 'package:flutter/material.dart';
import '../services/game_loop/game_loop_service.dart';

/// Provider zur Verwaltung von Spielservices
class ServicesProvider with ChangeNotifier {
  late GameLoopService _gameLoopService;
  bool _initialized = false;

  // Getter
  GameLoopService get gameLoopService => _gameLoopService;
  bool get initialized => _initialized;

  // Initialisiere Services mit BuildContext
  void initialize(BuildContext context) {
    if (!_initialized) {
      _gameLoopService = GameLoopService(context);
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
