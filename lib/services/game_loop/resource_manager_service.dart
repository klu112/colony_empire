import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/resources/resources_model.dart';
import '../../providers/game_provider.dart';
import '../../services/game_manager.dart';

/// Service zur Verwaltung und Aktualisierung von Ressourcen im Spielablauf
class ResourceManagerService {
  /// Der GameProvider für den Zugriff auf Spielressourcen
  final GameProvider gameProvider;

  /// Der GameManager für Zugriff auf zentrale Spielsysteme
  final GameManager gameManager;

  /// Zufallsgenerator für Ressourceneffekte
  final Random _random = Random();

  /// Erstellt einen neuen ResourceManagerService
  ResourceManagerService({
    required this.gameProvider,
    required this.gameManager,
  });

  /// Aktualisiert die Ressourcen basierend auf Spielzustand
  void updateResources() {
    // Die Grundregel-Updates vom GameProvider
    gameProvider.updateResources();

    // Zusätzliche komplexe Ressourcenberechnungen
    calculateFoodConsumption();
    calculateWaterConsumption();
    calculateBuildingMaterialCollection();

    // Überprüfe Kammerbauprozesse
    gameManager.updateChamberConstructionProgress();
  }

  /// Aktualisiert die Nahrungsproduktion und -verbrauch
  void calculateFoodConsumption() {
    final resources = gameProvider.resources;
    final taskAllocation = gameProvider.taskAllocation;

    // Nahrung sammeln basierend auf Zuweisung
    double foodCollected = 0.0;

    // Arbeiterzuweisung für Nahrungssuche
    final foragingPercentage = taskAllocation.foraging / 100.0;

    // Anzahl der Arbeiter für Nahrungssuche
    final foragingWorkers =
        (gameProvider.resources.population['workers'] ?? 0) *
        foragingPercentage;

    // Nahrungsmenge basierend auf Arbeitern und Effizienz
    // Hier war der Fehler: resources.calculateWorkEfficiency() könnte null sein
    if (resources != null) {
      final efficiency = resources.calculateWorkEfficiency();
      foodCollected = foragingWorkers * 0.2 * efficiency;

      // Umgebungseinflüsse (wie Jahreszeit, Wetter)
      // Später könnte hier ein komplexeres Modell implementiert werden
      final environmentFactor = 0.8 + (_random.nextDouble() * 0.4); // 0.8-1.2
      foodCollected *= environmentFactor;

      // Erfolgsrate bei der Nahrungssuche - manchmal gibt es Glückstreffer
      if (_random.nextDouble() < 0.05) {
        // 5% Chance
        foodCollected *= 1.5; // 50% Bonus
      }

      // Aktualisierte Ressourcen mit Verbrauch (über GameManager)
      gameProvider.updateResourcesFromService(
        resources.updateFoodConsumption(foodCollected),
      );
    }
  }

  /// Berechnet den Wasserverbrauch und die -sammlung
  void calculateWaterConsumption() {
    final resources = gameProvider.resources;
    final population = resources.population;

    // Basisverbrauch pro Ameise
    final baseConsumption = 0.01;

    // Gesamtverbrauch basierend auf Population
    double totalConsumption = 0.0;
    population.forEach((type, count) {
      // Verschiedene Kasten haben unterschiedlichen Bedarf
      double multiplier = 1.0;
      if (type == 'queens') multiplier = 2.0;
      if (type == 'soldiers') multiplier = 1.2;
      if (type == 'larvae') multiplier = 0.5;

      totalConsumption += count * baseConsumption * multiplier;
    });

    // Wassersammlung basierend auf Nahrungssuche-Aufgabe
    final waterCollection =
        (gameProvider.taskAllocation.foraging / 100.0) * 0.3;

    // Nettoänderung berechnen
    final netWaterChange = waterCollection - totalConsumption;

    // Aktualisiere Wasser (maximal 100, minimal 0)
    final newWaterLevel = (resources.water + netWaterChange).clamp(0.0, 100.0);

    // Aktualisierte Ressourcen
    gameProvider.updateResourcesFromService(
      resources.copyWith(water: newWaterLevel),
    );
  }

  /// Berechnet die Sammlung von Baumaterialien
  void calculateBuildingMaterialCollection() {
    final resources = gameProvider.resources;

    // Arbeiter, die Baumaterialien sammeln basierend auf Aufgabenzuweisung
    final builderPercentage = gameProvider.taskAllocation.building / 100.0;
    final builders = (resources.population['workers'] ?? 0) * builderPercentage;

    // Materialgewinnung pro Tick basierend auf Arbeiterzahl
    double materialsCollected = builders * 0.15;

    // Effizienzmultiplikator
    materialsCollected *= resources.calculateWorkEfficiency();

    // Aktualisiere Baumaterialien (maximal 100)
    final newMaterials = (resources.buildingMaterials + materialsCollected)
        .clamp(0.0, 100.0);

    // Aktualisierte Ressourcen
    gameProvider.updateResourcesFromService(
      resources.copyWith(buildingMaterials: newMaterials),
    );
  }
}
