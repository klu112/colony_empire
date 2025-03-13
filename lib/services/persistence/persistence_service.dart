import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/colony_model.dart';
import '../../providers/game_provider.dart';
import '../../utils/constants/game_enums.dart';
import 'colony_repository.dart';

/// Service zur Verwaltung der Spielstandspeicherung und -ladung
class PersistenceService {
  final BuildContext context;
  final ColonyRepository _repository = ColonyRepository();

  PersistenceService(this.context);

  /// Speichere aktuellen Spielstand
  Future<bool> saveGame() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final colony = gameProvider.colony;

    return await _repository.saveColony(colony);
  }

  /// Lade Spielstand
  Future<bool> loadGame() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final loadedColony = await _repository.loadColony();

    if (loadedColony != null) {
      gameProvider.loadColony(loadedColony);
      gameProvider.setGameState(GameState.playing);
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

  /// Auto-Save-Funktion, die in regelmäßigen Abständen speichert
  void enableAutoSave({Duration interval = const Duration(minutes: 2)}) {
    // Timer für regelmäßiges Speichern
    Future.doWhile(() async {
      await Future.delayed(interval);

      // Nur speichern, wenn das Spiel läuft
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (gameProvider.gameState == GameState.playing) {
        await saveGame();
      }

      // Weiterlaufen, solange der Kontext gültig ist
      return context.mounted;
    });
  }
}
