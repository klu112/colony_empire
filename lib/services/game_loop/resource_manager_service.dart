import 'dart:math';
import '../../models/resources/resources_model.dart';
import '../../models/resources/task_allocation_model.dart';

/// Service zur Verwaltung von Spielressourcen
class ResourceManagerService {
  final Random _random = Random();

  /// Aktualisiere Ressourcen basierend auf Spielzustand
  Resources updateResources({
    required Resources currentResources,
    required TaskAllocation taskAllocation,
    required String? selectedSpeciesId,
    required int time,
  }) {
    // Spezies-Bonus ermitteln
    final foodBonus = selectedSpeciesId == 'atta' ? 1.5 : 1.0;
    final reproductionBonus = selectedSpeciesId == 'solenopsis' ? 1.3 : 1.0;

    // Ressourcenänderungen berechnen
    final foodChange = calculateFoodChange(taskAllocation, foodBonus);
    final materialChange = calculateMaterialChange(taskAllocation);
    final waterChange = calculateWaterChange(taskAllocation);

    // Populationsänderungen berechnen
    final Map<String, int> newPopulation = Map.from(
      currentResources.population,
    );

    // Alle 10 Ticks Chance auf Eierschlupf basierend auf Brutpflege
    if (time % 10 == 0) {
      processEggAndLarvaDevelopment(
        newPopulation,
        taskAllocation,
        reproductionBonus,
      );

      // Königin legt Eier basierend auf Nahrung
      if (currentResources.food > 20 && time % 20 == 0) {
        processEggLaying(newPopulation, reproductionBonus);
      }
    }

    // Berechne Nahrungsverbrauch durch Bevölkerung
    final foodConsumption = calculateFoodConsumption(newPopulation);

    // Aktualisiere Ressourcen
    return currentResources.copyWith(
      food: (currentResources.food + foodChange - foodConsumption).clamp(
        0.0,
        100.0,
      ),
      buildingMaterials: (currentResources.buildingMaterials + materialChange)
          .clamp(0.0, 100.0),
      water: (currentResources.water + waterChange - 0.1).clamp(0.0, 100.0),
      population: newPopulation,
    );
  }

  /// Berechne Nahrungsänderung
  double calculateFoodChange(
    TaskAllocation taskAllocation,
    double speciesBonus,
  ) {
    return taskAllocation.foraging / 25 * speciesBonus;
  }

  /// Berechne Änderung der Baumaterialien
  double calculateMaterialChange(TaskAllocation taskAllocation) {
    return taskAllocation.building / 40;
  }

  /// Berechne Wasseränderung
  double calculateWaterChange(TaskAllocation taskAllocation) {
    return taskAllocation.foraging / 50;
  }

  /// Verarbeite Ei- und Larvenentwicklung
  void processEggAndLarvaDevelopment(
    Map<String, int> population,
    TaskAllocation taskAllocation,
    double reproductionBonus,
  ) {
    final hatchChance = taskAllocation.caregiving / 100 * reproductionBonus;

    // Eier zu Larven
    if (_random.nextDouble() < hatchChance && population['eggs']! > 0) {
      population['eggs'] = population['eggs']! - 1;
      population['larvae'] = population['larvae']! + 1;
    }

    // Larven zu Arbeiterinnen
    if (_random.nextDouble() < hatchChance && population['larvae']! > 0) {
      population['larvae'] = population['larvae']! - 1;
      population['workers'] = population['workers']! + 1;
    }
  }

  /// Verarbeite Eiablage durch Königin
  void processEggLaying(Map<String, int> population, double reproductionBonus) {
    final baseEggs = 1;
    final bonusEggs = reproductionBonus > 1.0 ? 1 : 0;

    population['eggs'] = population['eggs']! + baseEggs + bonusEggs;
  }

  /// Berechne Nahrungsverbrauch der Kolonie
  double calculateFoodConsumption(Map<String, int> population) {
    // Basisverbrauch pro Ameisentyp
    final workerConsumption = 0.05 * population['workers']!;
    final soldierConsumption = 0.1 * (population['soldiers'] ?? 0);
    final scoutConsumption = 0.05 * (population['scouts'] ?? 0);
    final queenConsumption = 0.2 * population['queen']!;
    final larvaeConsumption = 0.03 * population['larvae']!;

    return workerConsumption +
        soldierConsumption +
        scoutConsumption +
        queenConsumption +
        larvaeConsumption;
  }
}
