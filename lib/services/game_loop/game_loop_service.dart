import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';

/// Service zur Verwaltung des Spielablaufs in festen Zeitintervallen
class GameLoopService {
  final BuildContext context;
  Timer? _gameLoopTimer;
  final int _normalTickMs = 500; // Normale Geschwindigkeit
  final int _fastTickMs = 200; // Beschleunigte Geschwindigkeit

  GameLoopService(this.context);

  /// Startet den Game Loop
  void startGameLoop() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Bestehenden Timer stoppen, falls vorhanden
    stopGameLoop();

    // Wenn Geschwindigkeit auf 0 (Pause), nicht starten
    if (gameProvider.speed == 0) return;

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
    if (gameProvider.gameState != 'playing' || gameProvider.speed == 0) {
      stopGameLoop();
      return;
    }

    // Zeit aktualisieren
    gameProvider.updateTime();

    // Ameisen bewegen
    gameProvider.updateAnts();

    // Ressourcen aktualisieren
    gameProvider.updateResources();

    // Zufällige Ereignisse (ca. alle 50 Ticks)
    if (gameProvider.time % 50 == 0 && gameProvider.time > 0) {
      gameProvider.triggerRandomEvent();
    }
  }

  /// Geschwindigkeit ändern und Loop neu starten
  void setSpeed(int speed) {
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
