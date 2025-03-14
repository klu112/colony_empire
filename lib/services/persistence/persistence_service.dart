import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:colony_empire/utils/constants/game_enums.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/colony_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/services_provider.dart';
import 'colony_repository.dart';

/// Service zur Verwaltung der Spielpersistenz
class PersistenceService {
  static const String _saveFileName = 'colony_save.json';
  Timer? _autoSaveTimer;
  GameProvider? _gameProvider;
  final ColonyRepository _repository = ColonyRepository();

  // Konstruktor ohne Context-Abhängigkeit
  PersistenceService();

  // GameProvider setzen für späteren Zugriff
  void setGameProvider(GameProvider provider) {
    _gameProvider = provider;
  }

  /// Initialisiert den PersistenceService mit einer GameProvider-Instanz
  void initialize(GameProvider gameProvider) {
    _gameProvider = gameProvider;
    print('PersistenceService: Initialized with GameProvider');
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
      print('PersistenceService: Cannot save game, GameProvider is null');
      return false;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_saveFileName');

      // Aktuellen Koloniezustand serialisieren
      final colonyJson = _gameProvider!.colony.toJson();
      final gameStateJson = {
        'colony': colonyJson,
        'gameState': _gameProvider!.gameState.toString(),
        'lastSaved': DateTime.now().toIso8601String(),
      };

      // In Datei schreiben
      await file.writeAsString(jsonEncode(gameStateJson));
      print('PersistenceService: Game saved successfully');
      return true;
    } catch (e) {
      print('PersistenceService: Error saving game: $e');
      return false;
    }
  }

  /// Lade Spielstand
  Future<bool> loadGame() async {
    if (_gameProvider == null) {
      print('PersistenceService: Cannot load game, GameProvider is null');
      return false;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_saveFileName');

      if (!await file.exists()) {
        print('PersistenceService: No saved game found');
        return false;
      }

      final jsonString = await file.readAsString();
      final gameStateJson = jsonDecode(jsonString);

      // Kolonie aus JSON erstellen
      final savedColony = Colony.fromJson(gameStateJson['colony']);

      // In GameProvider laden
      _gameProvider!.loadColony(savedColony);
      _gameProvider!.setGameStateFromString(gameStateJson['gameState']);

      print('PersistenceService: Game loaded successfully');
      return true;
    } catch (e) {
      print('PersistenceService: Error loading game: $e');
      return false;
    }
  }

  /// Prüfe, ob ein Spielstand existiert
  Future<bool> hasSavedGame() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_saveFileName');
      return await file.exists();
    } catch (e) {
      print('PersistenceService: Error checking for saved game: $e');
      return false;
    }
  }

  /// Lösche Spielstand
  Future<bool> deleteSave() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_saveFileName');

      if (await file.exists()) {
        await file.delete();
        print('PersistenceService: Saved game deleted');
      }

      return true;
    } catch (e) {
      print('PersistenceService: Error deleting saved game: $e');
      return false;
    }
  }
}
