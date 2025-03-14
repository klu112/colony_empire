import 'dart:async';
import 'package:flutter/material.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/game_enums.dart';
import 'ant_manager_service.dart';
import 'resource_manager_service.dart';

/// Service zur Verwaltung des Spielablaufs in festen Zeitintervallen
class GameLoopService {
  // Direkte Referenz zum GameProvider anstatt BuildContext
  GameProvider? _gameProvider;
  Timer? _gameLoopTimer;
  final int _normalTickMs = 500; // Normale Geschwindigkeit
  final int _fastTickMs = 200; // Beschleunigte Geschwindigkeit
  int _currentSpeed = 1;

  // Unterservices
  final AntManagerService _antManagerService = AntManagerService();
  final ResourceManagerService _resourceManagerService =
      ResourceManagerService();

  // Konstruktor ohne BuildContext
  GameLoopService();

  // Methode zum Setzen des GameProviders
  void setGameProvider(GameProvider provider) {
    _gameProvider = provider;
    print('GameLoopService: GameProvider set');
  }

  void startGameLoop() {
    // Nur starten, wenn nicht bereits aktiv
    if (_gameLoopTimer != null && _gameLoopTimer!.isActive) {
      print('Game loop already running, skipping start');
      return;
    }

    // Wenn Geschwindigkeit auf 0 (Pause), nicht starten
    if (_currentSpeed == 0) {
      print('Game speed is 0, not starting game loop');
      return;
    }

    // GameProvider prüfen
    if (_gameProvider == null) {
      print('GameProvider is null, cannot start game loop');
      return;
    }

    // Debug-Ausgabe hinzufügen
    print('Starting game loop with speed: $_currentSpeed');

    // Timer-Intervall basierend auf Geschwindigkeit
    final tickMs = _currentSpeed == 1 ? _normalTickMs : _fastTickMs;

    // Sichereres Timer-Setup mit Try-Catch
    try {
      _gameLoopTimer = Timer.periodic(Duration(milliseconds: tickMs), (timer) {
        _processTick();
      });
    } catch (e) {
      print('Error starting game loop: $e');
    }
  }

  /// Stoppt den Game Loop
  void stopGameLoop() {
    if (_gameLoopTimer != null) {
      print('Stopping game loop');
      _gameLoopTimer!.cancel();
      _gameLoopTimer = null;
    }
  }

  /// Verarbeitet einen einzelnen Tick des Spiels
  void _processTick() {
    // Sicherer Zugriff auf GameProvider
    final gameProvider = _gameProvider;
    if (gameProvider == null) {
      print('GameProvider is null in processTick, stopping game loop');
      stopGameLoop();
      return;
    }

    try {
      // Nur verarbeiten, wenn das Spiel läuft
      if (gameProvider.gameState != GameState.playing || _currentSpeed == 0) {
        print('Game not in playing state or speed is 0, stopping game loop');
        stopGameLoop();
        return;
      }

      // Zeit aktualisieren
      gameProvider.updateTime();

      // Ressourcen aktualisieren mit ResourceManagerService
      final updatedResources = _resourceManagerService.updateResources(
        currentResources: gameProvider.resources,
        taskAllocation: gameProvider.taskAllocation,
        selectedSpeciesId: gameProvider.selectedSpeciesId,
        time: gameProvider.time,
      );

      // Update direkt im GameProvider durchführen
      gameProvider.updateResourcesFromService(updatedResources);

      // Ameisen aktualisieren mit AntManagerService
      if (gameProvider.ants.isEmpty) {
        // Initialisiere Ameisen, wenn noch keine vorhanden sind
        final initialAnts = _antManagerService.initializeAnts(
          gameProvider.chambers,
          gameProvider.resources,
        );
        gameProvider.updateAntsFromService(initialAnts);
      } else {
        // Bewege vorhandene Ameisen
        final updatedAnts = _antManagerService.updateAnts(
          gameProvider.ants,
          gameProvider.chambers,
          gameProvider.taskAllocation,
        );
        gameProvider.updateAntsFromService(updatedAnts);
      }

      // Zufällige Ereignisse (ca. alle 50 Ticks)
      if (gameProvider.time % 50 == 0 && gameProvider.time > 0) {
        gameProvider.triggerRandomEvent();
      }
    } catch (e, stackTrace) {
      print('Error in game loop: $e');
      print('Stack trace: $stackTrace');
      // Bei Fehlern den Loop nicht beenden, damit das Spiel weiterläuft
    }
  }

  /// Geschwindigkeit ändern und Loop neu starten
  void setSpeed(int speed) {
    print('GameLoopService: Setting game speed to: $speed');
    _currentSpeed = speed;

    // Game Loop neu starten bei Geschwindigkeitsänderung
    stopGameLoop();
    if (speed > 0) {
      startGameLoop();
    }
  }
}
