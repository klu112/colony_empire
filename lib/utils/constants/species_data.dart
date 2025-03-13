import '../../models/species/species_model.dart';

/// Daten für die verfügbaren Ameisenarten
class SpeciesData {
  static List<Species> all = [
    const Species(
      id: 'atta',
      name: 'Blattschneiderameisen',
      scientificName: 'Atta',
      color: 'green',
      description: 'Spezialisierung: Landwirtschaft und Nahrungsproduktion',
      strengths: 'Höhere Nahrungsproduktion, können Pilzgärten anlegen',
      weaknesses: 'Anfälliger für Angriffe, langsamere Vermehrung',
      bonuses: {'foodProduction': 1.5, 'gardenUnlock': 1.0},
    ),
    const Species(
      id: 'oecophylla',
      name: 'Weberameisen',
      scientificName: 'Oecophylla',
      color: 'yellow',
      description: 'Spezialisierung: Baumeister und Verteidigung',
      strengths: 'Bessere Neststruktur, starke Verteidigung',
      weaknesses: 'Ineffizientere Nahrungssuche',
      bonuses: {'buildingDurability': 1.5, 'defense': 1.3},
    ),
    const Species(
      id: 'eciton',
      name: 'Wanderameisen',
      scientificName: 'Eciton',
      color: 'red',
      description: 'Spezialisierung: Militär und Expansion',
      strengths: 'Starke Kriegerfähigkeiten, schnellere Erkundung',
      weaknesses: 'Höherer Nahrungsbedarf, instabilere Nester',
      bonuses: {'combatStrength': 1.8, 'explorationSpeed': 1.5},
    ),
    const Species(
      id: 'solenopsis',
      name: 'Feuerameisen',
      scientificName: 'Solenopsis',
      color: 'orange',
      description: 'Spezialisierung: Anpassungsfähigkeit',
      strengths:
          'Widerstandsfähig gegen Umweltbedingungen, schnelle Vermehrung',
      weaknesses: 'Keine speziellen Boni in einem bestimmten Bereich',
      bonuses: {'environmentalResistance': 1.4, 'reproductionRate': 1.3},
    ),
  ];

  static Species getById(String id) {
    return all.firstWhere((species) => species.id == id, orElse: () => all[0]);
  }
}
