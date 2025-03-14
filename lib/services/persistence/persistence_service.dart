import 'dart:async';
import 'package:colony_empire/utils/constants/game_enums.dart';
import 'package:flutter/material.dart';
import '../../models/colony_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/services_provider.dart';
import 'colony_repository.dart';

/// Service zur Verwaltung der Spielpersistenz
class PersistenceService {
  Timer? _autoSaveTimer;
  GameProvider? _gameProvider;
  final ColonyRepository _repository = ColonyRepository();

  // Konstruktor ohne Context-Abhängigkeit
  PersistenceService();

  // GameProvider setzen für späteren Zugriff
  void setGameProvider(GameProvider provider) {
    _gameProvider = provider;
  }

  // Auto-Save aktivieren
  void enableAutoSave() {
    // Auto-Save alle 5 Minuten
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      // Hier später Save-Logik implementieren
      print('Auto-save triggered');
      if (_gameProvider != null) {
        saveGame();
      }
    });
  }

  // Auto-Save deaktivieren
  void disableAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// Speichere aktuellen Spielstand
  Future<bool> saveGame() async {
    if (_gameProvider == null) {
      print('Cannot save: GameProvider is null');
      return false;
    }

    final colony = _gameProvider!.colony;
    print('Saving game...');

    return await _repository.saveColony(colony);
  }

  /// Lade Spielstand
  Future<bool> loadGame() async {
    if (_gameProvider == null) {
      print('Cannot load: GameProvider is null');
      return false;
    }

    print('Loading game...');
    final loadedColony = await _repository.loadColony();
    if (loadedColony != null) {
      _gameProvider!.loadColony(loadedColony);
      _gameProvider!.setGameState(GameState.playing);
      return true;
    }

    return false;
  }

  /// Prüfe, ob ein Spielstand existiert
  Future<bool> hasSavedGame() async {
    return await _repository.hasSavedColony();
  }

  /// Lösche Spielstand
  Future<bool> deleteSave() async {
    return await _repository.deleteColonySave();
  }
}
