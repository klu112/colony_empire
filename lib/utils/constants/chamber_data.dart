/// Daten und Definitionen für verschiedene Kammertypen
class ChamberData {
  static Map<String, Map<String, dynamic>> types = {
    'queen': {
      'name': 'Königinnenkammer',
      'icon': '👑',
      'description': 'Hier lebt die Königin und legt Eier.',
      'cost': 0, // Starterkammer
      'unlockRequirements': {},
    },
    'nursery': {
      'name': 'Brutkammer',
      'icon': '🥚',
      'description': 'Hier werden Eier und Larven aufgezogen.',
      'cost': 20,
      'unlockRequirements': {},
    },
    'storage': {
      'name': 'Vorratskammer',
      'icon': '🍯',
      'description': 'Speichert Nahrung und Baumaterialien.',
      'cost': 20,
      'unlockRequirements': {},
    },
    'waste': {
      'name': 'Abfallkammer',
      'icon': '🗑️',
      'description': 'Speichert Abfälle und verhindert Krankheiten.',
      'cost': 15,
      'unlockRequirements': {'population': 10},
    },
    'defense': {
      'name': 'Verteidigungskammer',
      'icon': '🛡️',
      'description': 'Verbessert die Verteidigung gegen Eindringlinge.',
      'cost': 25,
      'unlockRequirements': {'population': 15},
    },
    'garden': {
      'name': 'Pilzgarten',
      'icon': '🍄',
      'description': 'Ermöglicht den Anbau von Pilzen als Nahrungsquelle.',
      'cost': 30,
      'unlockRequirements': {'species': 'atta', 'population': 20},
    },
  };

  static Map<String, dynamic> getTypeInfo(String type) {
    return types[type] ?? types['storage']!;
  }

  static bool isChamberUnlocked(
    String type,
    String? speciesId,
    Map<String, int> population,
  ) {
    final requirements = types[type]?['unlockRequirements'] ?? {};

    // Speziesanforderung prüfen
    if (requirements.containsKey('species') &&
        requirements['species'] != speciesId) {
      return false;
    }

    // Populationsanforderung prüfen
    if (requirements.containsKey('population')) {
      final totalPopulation = population.values.fold(
        0,
        (sum, count) => sum + count,
      );
      if (totalPopulation < requirements['population']) {
        return false;
      }
    }

    return true;
  }
}
