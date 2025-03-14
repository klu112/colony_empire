import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/game_enums.dart';
import 'ant_manager_service.dart';
import 'resource_manager_service.dart';

/// Service zur Verwaltung des Spielablaufs in festen Zeitintervallen
class GameLoopService {
  final BuildContext context;
  Timer? _gameLoopTimer;
  final int _normalTickMs = 500; // Normale Geschwindigkeit
  final int _fastTickMs = 200; // Beschleunigte Geschwindigkeit

  // Unterservices
  final AntManagerService _antManagerService = AntManagerService();
  final ResourceManagerService _resourceManagerService =
      ResourceManagerService();

  GameLoopService(this.context);

  void startGameLoop() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Bestehenden Timer stoppen, falls vorhanden
    stopGameLoop();

    // Wenn Geschwindigkeit auf 0 (Pause), nicht starten
    if (gameProvider.speed == 0) return;

    // Debug-Ausgabe hinzufügen
    print('Starting game loop with speed: ${gameProvider.speed}');

    // Timer-Intervall basierend auf Geschwindigkeit
    final tickMs = gameProvider.speed == 1 ? _normalTickMs : _fastTickMs;

    _gameLoopTimer = Timer.periodic(Duration(milliseconds: tickMs), (_) {
      _processTick();
    });
  }

  /// Stoppt den Game Loop
  void stopGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
  }

  /// Verarbeitet einen einzelnen Tick des Spiels
  void _processTick() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    // Nur verarbeiten, wenn das Spiel läuft
    if (gameProvider.gameState != GameState.playing ||
        gameProvider.speed == 0) {
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
  }

  /// Geschwindigkeit ändern und Loop neu starten
  void setSpeed(int speed) {
    print('Setting game speed to: $speed');
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.setSpeed(speed);

    // Game Loop neu starten mit neuer Geschwindigkeit
    if (speed > 0) {
      startGameLoop();
    } else {
      stopGameLoop();
    }
  }
}
