import 'dart:math';
import '../../models/resources/resources_model.dart';
import '../../models/resources/task_allocation_model.dart';
import '../../providers/game_provider.dart';

/// Repräsentiert die verschiedenen Lebensstadien einer Ameise
enum AntLifeStage {
  /// Ei-Stadium
  egg,

  /// Larven-Stadium
  larva,

  /// Puppen-Stadium
  pupa,

  /// Erwachsenen-Stadium (Arbeiter, Soldat, etc.)
  adult,
}

/// Service zur Verwaltung des Lebenszyklus der Ameisen
class AntLifecycleManager {
  /// Der aktuelle Game Provider für den Zugriff auf den Spielzustand
  final GameProvider _gameProvider;

  /// Random-Generator für Wahrscheinlichkeitsberechnungen
  final Random _random = Random();

  /// Entwicklungsdauer in Spielticks für jedes Stadium
  static const Map<AntLifeStage, int> _developmentDuration = {
    AntLifeStage.egg: 15, // 15 Ticks als Ei
    AntLifeStage.larva: 20, // 20 Ticks als Larve
    AntLifeStage.pupa: 25, // 25 Ticks als Puppe
  };

  /// Nahrungsbedarf pro Tick für jedes Stadium
  static const Map<AntLifeStage, double> _foodRequirementPerTick = {
    AntLifeStage.egg: 0.01, // Eier brauchen minimal Nahrung
    AntLifeStage.larva: 0.05, // Larven brauchen mehr Nahrung
    AntLifeStage.pupa: 0.03, // Puppen brauchen weniger als Larven
    AntLifeStage.adult: 0.1, // Erwachsene brauchen am meisten
  };

  /// Einfluss der Brutpflege auf die Entwicklungsgeschwindigkeit
  /// Bei 0% Brutpflege dauert die Entwicklung länger, bei 100% kürzer
  static const double _caregivingEfficiencyFactor = 0.5;

  /// Erstellt einen neuen AntLifecycleManager
  AntLifecycleManager(this._gameProvider);

  /// Führt einen Update-Schritt des Lebenszyklus durch
  void update() {
    // Aktualisiere die Lebensstadien
    _updateLifecycleStages();

    // Aktualisiere die Eiproduktion
    _updateEggProduction();
  }

  /// Aktualisiert die Lebensstadien der Ameisen in der Kolonie
  void _updateLifecycleStages() {
    final resources = _gameProvider.resources;
    final taskAllocation = _gameProvider.taskAllocation;

    // Überprüfe, ob ein Update der Lebensphasen notwendig ist (z.B. alle 10 Ticks)
    final currentTick = _gameProvider.time;
    if (currentTick % 10 != 0) return;

    // Berechne Faktoren, die die Entwicklung beeinflussen
    final caregivingEfficiency = _calculateCaregivingEfficiency(taskAllocation);
    final foodAvailability = _calculateFoodAvailability(resources);

    // Aktualisiere die Population
    final populationChanges = _calculateLifecycleProgression(
      resources.population,
      caregivingEfficiency,
      foodAvailability,
    );

    // Wende die Änderungen auf die Ressourcen an
    if (populationChanges.isNotEmpty) {
      final newPopulation = Map<String, int>.from(resources.population);

      populationChanges.forEach((key, value) {
        newPopulation[key] = (newPopulation[key] ?? 0) + value;
      });

      // Stellen sicher, dass keine negativen Werte entstehen
      newPopulation.forEach((key, value) {
        newPopulation[key] = max(0, value);
      });

      // Aktualisiere die Ressourcen mit der neuen Population
      final updatedResources = resources.copyWith(population: newPopulation);
      _gameProvider.updateResourcesFromService(updatedResources);
    }
  }

  /// Berechnet die Änderungen in der Population durch Lebensstadien-Progression
  Map<String, int> _calculateLifecycleProgression(
    Map<String, int> currentPopulation,
    double caregivingEfficiency,
    double foodAvailability,
  ) {
    final changes = <String, int>{};

    // Entwicklungschancen basierend auf Effizienzfaktoren
    final double eggToLarvaChance = _calculateProgressionChance(
      AntLifeStage.egg,
      caregivingEfficiency,
      foodAvailability,
    );

    final double larvaToPupaChance = _calculateProgressionChance(
      AntLifeStage.larva,
      caregivingEfficiency,
      foodAvailability,
    );

    final double pupaToAdultChance = _calculateProgressionChance(
      AntLifeStage.pupa,
      caregivingEfficiency,
      foodAvailability,
    );

    // Berechne, wie viele Ameisen in das nächste Stadium übergehen
    int eggsToLarvae = _calculateTransitions(
      currentPopulation['eggs'] ?? 0,
      eggToLarvaChance,
    );

    int larvaeToPupae = _calculateTransitions(
      currentPopulation['larvae'] ?? 0,
      larvaToPupaChance,
    );

    int pupaeToAdults = _calculateTransitions(
      currentPopulation['pupae'] ?? 0,
      pupaToAdultChance,
    );

    // Aktualisiere die Änderungen
    if (eggsToLarvae > 0) {
      changes['eggs'] = -eggsToLarvae;
      changes['larvae'] = eggsToLarvae;
    }

    if (larvaeToPupae > 0) {
      changes['larvae'] = (changes['larvae'] ?? 0) - larvaeToPupae;
      changes['pupae'] = larvaeToPupae;
    }

    if (pupaeToAdults > 0) {
      changes['pupae'] = (changes['pupae'] ?? 0) - pupaeToAdults;

      // Entscheide, was für eine Art von Erwachsenem entsteht
      // Standardmäßig werden Arbeiterinnen erzeugt
      changes['workers'] = pupaeToAdults;

      // Mit geringer Wahrscheinlichkeit können auch Soldaten entstehen
      final int soldiersProduced = _determineSoldiersProduction(pupaeToAdults);
      if (soldiersProduced > 0) {
        changes['workers'] = (changes['workers'] ?? 0) - soldiersProduced;
        changes['soldiers'] = soldiersProduced;
      }
    }

    return changes;
  }

  /// Berechnet die Chance für den Übergang zum nächsten Lebensstadium
  double _calculateProgressionChance(
    AntLifeStage stage,
    double caregivingEfficiency,
    double foodAvailability,
  ) {
    // Basis-Übergangswahrscheinlichkeit für das Stadium
    final baseChance = 1.0 / _developmentDuration[stage]!;

    // Brutpflege-Faktor: mehr Brutpflege = schnellere Entwicklung
    final caregivingFactor =
        1.0 + (caregivingEfficiency * _caregivingEfficiencyFactor);

    // Nahrungsfaktor: wenig Nahrung verlangsamt Entwicklung drastisch
    final foodFactor = _calculateFoodFactor(foodAvailability, stage);

    // Kombination der Faktoren (begrenzt auf eine sinnvolle Obergrenze)
    return min(baseChance * caregivingFactor * foodFactor, 0.5);
  }

  /// Berechnet den Einfluss der Nahrungsverfügbarkeit auf die Entwicklung
  double _calculateFoodFactor(double foodAvailability, AntLifeStage stage) {
    // Bei voller Nahrungsverfügbarkeit ist der Faktor 1.0
    // Bei geringer Verfügbarkeit sinkt der Faktor stark ab
    if (foodAvailability >= 0.9) return 1.0;
    if (foodAvailability >= 0.7) return 0.8;
    if (foodAvailability >= 0.5) return 0.6;
    if (foodAvailability >= 0.3) return 0.3;

    // Bei extremer Nahrungsknappheit ist die Entwicklung stark verlangsamt
    // aber für Eier weniger drastisch als für Larven
    if (stage == AntLifeStage.egg) return 0.2;
    return 0.1;
  }

  /// Berechnet, wie viele Individuen das nächste Stadium erreichen
  int _calculateTransitions(int count, double chance) {
    if (count <= 0) return 0;

    int transitions = 0;
    for (int i = 0; i < count; i++) {
      if (_random.nextDouble() < chance) {
        transitions++;
      }
    }
    return transitions;
  }

  /// Bestimmt, wie viele der neuen Erwachsenen Soldaten werden
  int _determineSoldiersProduction(int totalNewAdults) {
    // Standardmäßig werden 10% der neuen Erwachsenen zu Soldaten
    // Dies könnte später von verschiedenen Faktoren abhängen (Bedrohungslevel, etc.)
    final double soldierRatio = 0.1;

    int potentialSoldiers = (totalNewAdults * soldierRatio).round();

    // Stochastische Bestimmung
    int actualSoldiers = 0;
    for (int i = 0; i < potentialSoldiers; i++) {
      if (_random.nextDouble() < soldierRatio * 2) {
        // Doppelte Chance für individuelle Bestimmung
        actualSoldiers++;
      }
    }

    return actualSoldiers;
  }

  /// Aktualisiert die Eiproduktion der Königin
  void _updateEggProduction() {
    final resources = _gameProvider.resources;
    final currentTick = _gameProvider.time;

    // Überprüfe, ob ein Eiproduktions-Update ansteht (z.B. alle 20 Ticks)
    if (currentTick % 20 != 0) return;

    // Berechne die Eiproduktion basierend auf dem Gesundheitszustand der Königin
    final int newEggs = _calculateQueenEggProduction(resources);

    if (newEggs > 0) {
      // Aktualisiere die Ressourcen mit den neuen Eiern
      final newPopulation = Map<String, int>.from(resources.population);
      newPopulation['eggs'] = (newPopulation['eggs'] ?? 0) + newEggs;

      final updatedResources = resources.copyWith(population: newPopulation);
      _gameProvider.updateResourcesFromService(updatedResources);
    }
  }

  /// Berechnet die Anzahl der von der Königin produzierten Eier
  int _calculateQueenEggProduction(Resources resources) {
    // Keine Eier, wenn die Königin verhungert oder tot ist
    if (resources.isQueenStarving() || resources.isQueenDead()) {
      return 0;
    }

    // Basisproduktion basierend auf der Gesundheit der Königin
    final baseProduction = resources.queenHealth / 25.0;

    // Nahrungsreserven beeinflussen die Produktion
    final foodFactor = _calculateFoodAvailability(resources);

    // Anzahl der Königinnen (normalerweise 1)
    final queensCount = resources.population['queens'] ?? 1;

    // Spezies-Boni könnten hier einbezogen werden
    final speciesBonus = _calculateSpeciesEggBonus();

    // Kombiniere alle Faktoren und runde auf eine ganze Zahl
    final int eggCount =
        (baseProduction * foodFactor * queensCount * speciesBonus).round();

    return max(0, eggCount);
  }

  /// Berechnet einen Artspezifischen Bonus für die Eiproduktion
  double _calculateSpeciesEggBonus() {
    final speciesId = _gameProvider.selectedSpeciesId;

    // Artspezifische Boni
    switch (speciesId) {
      case 'solenopsis': // Feuerameisen haben höhere Reproduktionsrate
        return 1.5;
      case 'messor': // Ernteameisen
        return 1.2;
      case 'atta': // Blattschneiderameisen
        return 1.1;
      case 'camponotus': // Rossameisen
        return 1.0;
      default:
        return 1.0;
    }
  }

  /// Berechnet die Effizienz der Brutpflegearbeiten (0.0 - 1.0)
  double _calculateCaregivingEfficiency(TaskAllocation taskAllocation) {
    // Basiseffizienz basierend auf der prozentualen Zuweisung zur Brutpflege
    double efficiency = taskAllocation.caregiving / 100.0;

    // Überprüfe, ob genug Arbeiter für die Brutpflege vorhanden sind
    final int totalWorkers = _gameProvider.resources.population['workers'] ?? 0;
    final int caregivers = (totalWorkers * efficiency).round();

    // Brutgröße (Eier + Larven + Puppen)
    final int broodSize =
        (_gameProvider.resources.population['eggs'] ?? 0) +
        (_gameProvider.resources.population['larvae'] ?? 0) +
        (_gameProvider.resources.population['pupae'] ?? 0);

    // Ideales Verhältnis: 1 Brutpflegerin für je 3 Brut-Individuen
    final double idealRatio = broodSize / 3.0;

    // Effizienzfaktor basierend auf dem tatsächlichen Verhältnis
    if (caregivers <= 0)
      return 0.1; // Minimale Effizienz, selbst ohne Arbeiterinnen

    double ratioFactor = caregivers / idealRatio;

    // Effizienz ist begrenzt: zu viele Arbeiterinnen bringen nur wenig zusätzlichen Nutzen
    return min(efficiency * min(ratioFactor, 1.5), 1.0);
  }

  /// Berechnet die Nahrungsverfügbarkeit für die Kolonie (0.0 - 1.0)
  double _calculateFoodAvailability(Resources resources) {
    // Berechne das Verhältnis von verfügbarer zu benötigter Nahrung
    final double foodShortage = resources.calculateFoodShortage();

    // Umkehrung: 0 Mangel = 1.0 Verfügbarkeit, 1.0 Mangel = 0.0 Verfügbarkeit
    return 1.0 - foodShortage;
  }

  /// Berechnet den Gesamtnahrungsbedarf aller Lebensstadien
  double calculateTotalFoodRequirement() {
    final resources = _gameProvider.resources;
    double totalRequirement = 0.0;

    // Nahrungsbedarf für Eier
    totalRequirement +=
        (resources.population['eggs'] ?? 0) *
        _foodRequirementPerTick[AntLifeStage.egg]!;

    // Nahrungsbedarf für Larven
    totalRequirement +=
        (resources.population['larvae'] ?? 0) *
        _foodRequirementPerTick[AntLifeStage.larva]!;

    // Nahrungsbedarf für Puppen
    totalRequirement +=
        (resources.population['pupae'] ?? 0) *
        _foodRequirementPerTick[AntLifeStage.pupa]!;

    // Nahrungsbedarf für Arbeiterinnen
    totalRequirement +=
        (resources.population['workers'] ?? 0) *
        _foodRequirementPerTick[AntLifeStage.adult]!;

    // Nahrungsbedarf für Soldaten (1.5x höher als für normale Arbeiterinnen)
    totalRequirement +=
        (resources.population['soldiers'] ?? 0) *
        _foodRequirementPerTick[AntLifeStage.adult]! *
        1.5;

    // Nahrungsbedarf für die Königin (doppelt so hoch wie für normale Arbeiterinnen)
    totalRequirement +=
        (resources.population['queens'] ?? 0) *
        _foodRequirementPerTick[AntLifeStage.adult]! *
        2.0;

    return totalRequirement;
  }

  /// Simuliert Sterblichkeit bei extremer Nahrungsknappheit
  void simulateStarvationMortality() {
    final resources = _gameProvider.resources;

    // Bei starkem Hunger treten Sterbefälle auf
    if (resources.colonyHunger >= 50.0) {
      final mortalityMap = resources.calculateMortality();

      if (mortalityMap.values.any((value) => value > 0)) {
        final resourcesWithMortality = resources.applyMortality();
        _gameProvider.updateResourcesFromService(resourcesWithMortality);
      }
    }
  }
}
