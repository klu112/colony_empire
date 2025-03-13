/// Spielzustände
enum GameState {
  selection, // Ameisenart auswählen
  tutorial, // Tutorial durchlaufen
  playing, // Aktives Spielen
  paused, // Spiel pausiert
}

/// Spielgeschwindigkeit
enum GameSpeed {
  paused, // 0: Pausiert
  normal, // 1: Normale Geschwindigkeit
  fast, // 2: Erhöhte Geschwindigkeit
}

/// Aufgabentypen für Ameisen
enum TaskType {
  foraging, // Nahrungssammeln
  building, // Nestbau
  caregiving, // Brutpflege
  defense, // Verteidigung
  exploration, // Erkundung
}

/// Konvertierungen zwischen String und Enum
extension GameStateExtension on GameState {
  String get value {
    return toString().split('.').last;
  }

  static GameState fromString(String value) {
    return GameState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GameState.selection,
    );
  }
}

extension GameSpeedExtension on GameSpeed {
  int get value {
    return index;
  }

  static GameSpeed fromInt(int value) {
    return GameSpeed.values.firstWhere(
      (e) => e.index == value,
      orElse: () => GameSpeed.normal,
    );
  }
}

extension TaskTypeExtension on TaskType {
  String get value {
    return toString().split('.').last;
  }

  static TaskType fromString(String value) {
    return TaskType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskType.foraging,
    );
  }
}
