import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../providers/services_provider.dart';
import '../services/simulation/ant_lifecycle_manager.dart';
import '../services/simulation/pheromone_system.dart';
import '../services/view/view_manager.dart';
import '../utils/constants/game_enums.dart';
import '../models/resources/resources_model.dart';
import '../models/chamber/chamber_model.dart'; // Added import for ChamberState
import 'dart:async';
import 'dart:math';

/// GameManager koordiniert alle Spielsysteme und dient als zentrale Schnittstelle
/// zwischen Spiellogik und UI-Komponenten.
class GameManager {
  /// Der zentrale GameProvider für den Spielzustand
  final GameProvider gameProvider;

  /// Der ServicesProvider für Zugriff auf Services
  final ServicesProvider servicesProvider;

  /// Manager für die verschiedenen Ansichten (Nest/Oberfläche)
  late ViewManager viewManager;

  /// System zur Simulation von Pheromonspuren
  late PheromoneSystem pheromoneSystem;

  /// Manager für den Lebenszyklus der Ameisen
  late AntLifecycleManager lifecycleManager;

  /// Timer für regelmäßige Ereignisüberprüfung
  Timer? _eventTimer;

  /// Zufallsgenerator für Ereignisse
  final Random _random = Random();

  /// Zustand, ob der Manager initialisiert wurde
  bool _initialized = false;

  /// Gibt an, ob der GameManager initialisiert wurde
  bool get initialized => _initialized;

  /// Erstellt einen neuen GameManager
  GameManager({required this.gameProvider, required this.servicesProvider});

  /// Initialisiert alle Subsysteme des Spiels
  void initialize({required Size screenSize}) {
    // Verhindere doppelte Initialisierung
    if (_initialized) return;

    print('GameManager: Initialisiere Spielsysteme');

    // ViewManager initialisieren
    viewManager = ViewManager();

    // PheromoneSystem mit Bildschirmgröße initialisieren
    pheromoneSystem = PheromoneSystem(
      width: screenSize.width.toInt(),
      height: screenSize.height.toInt(),
      resolution: 10, // Niedrigere Auflösung für bessere Performance
    );

    // AntLifecycleManager initialisieren
    lifecycleManager = AntLifecycleManager(gameProvider);

    // Ereignis-Timer starten
    _startEventTimer();

    _initialized = true;

    print('GameManager: Spielsysteme initialisiert');
  }

  /// Startet den Timer für zufällige Ereignisse
  void _startEventTimer() {
    // Alle 15 Sekunden auf mögliche Ereignisse prüfen
    _eventTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (gameProvider.gameState == GameState.playing) {
        _checkForRandomEvents();
      }
    });
  }

  /// Prüft, ob ein zufälliges Ereignis ausgelöst werden soll
  void _checkForRandomEvents() {
    // Grundchance für ein Ereignis: 20%
    if (_random.nextDouble() < 0.2) {
      gameProvider.triggerRandomEvent();
    }

    // Prüfe auf Nahrungsknappheit-Effekte
    _checkStarvationEffects();
  }

  /// Prüft und wendet Effekte von Nahrungsmangel an
  void _checkStarvationEffects() {
    final resources = gameProvider.resources;

    // Bei hohem Hunger Sterblichkeit simulieren
    if (resources.colonyHunger > 50) {
      lifecycleManager.simulateStarvationMortality();
    }

    // Bei kritischem Hunger der Königin Warnung anzeigen
    if (resources.isQueenStarving() && !resources.isQueenDead()) {
      gameProvider.setNotification('Königin hungert! Bring dringend Nahrung!');
    }

    // Bei toter Königin Game-Over prüfen
    if (resources.isQueenDead()) {
      _checkGameOverCondition();
    }
  }

  /// Prüft, ob das Spiel verloren ist
  void _checkGameOverCondition() {
    final resources = gameProvider.resources;

    // Wenn die Königin tot ist und keine Arbeiter mehr da sind
    if (resources.isQueenDead() &&
        (resources.population['workers'] ?? 0) <= 0) {
      // Spiel in den Game-Over-Zustand versetzen
      gameProvider.setGameState(
        GameState.paused,
      ); // Changed from gameOver to paused
      gameProvider.setNotification(
        'Game Over: Deine Kolonie ist ausgestorben!',
      );

      // Alle Timer stoppen
      servicesProvider.gameLoopService.stopGameLoop();
    }
  }

  /// Aktualisiert den Spielzustand und alle Subsysteme
  void update() {
    if (!_initialized || gameProvider.gameState != GameState.playing) return;

    // Aktualisiere Pheromonsystem
    pheromoneSystem.update();

    // Aktualisiere Ameisen-Lebenszyklus
    lifecycleManager.update();

    // Aktualisiere Ressourcenverbrauch basierend auf dem Lebenszyklus-Manager
    _updateResourceConsumption();
  }

  /// Aktualisiert den Ressourcenverbrauch der Kolonie
  void _updateResourceConsumption() {
    // Aktuellen Tick nur alle 5 Ticks aktualisieren, um Performance zu sparen
    if (gameProvider.time % 5 != 0) return;

    final resources = gameProvider.resources;

    // Nahrungsproduktion basierend auf Nahrungssuche-Effizienz
    final foragingEfficiency = gameProvider.taskAllocation.foraging / 100;
    final foodProduction = foragingEfficiency * 2.0;

    // Ressourcen mit Verbrauch aktualisieren
    final updatedResources = resources.updateFoodConsumption(foodProduction);

    // Setze aktualisierte Ressourcen
    gameProvider.updateResourcesFromService(updatedResources);
  }

  /// Fügt eine Pheromonspur an einer bestimmten Position hinzu
  void addPheromone(
    Offset position,
    PheromoneType type, {
    double intensity = 0.5,
  }) {
    if (!_initialized) return;
    pheromoneSystem.addPheromone(position, type, intensity: intensity);
  }

  /// Wechselt zwischen Nest- und Oberflächen-Ansicht
  void switchView(GameView newView) {
    if (!_initialized) return;
    viewManager.switchToView(newView);
  }

  /// Initialisiert den Animation Controller für den ViewManager
  void initializeViewAnimations(AnimationController controller) {
    if (!_initialized) return;
    viewManager.initialize(controller);
  }

  /// Liefert eine Visualisierung des Pheromonsystems
  Widget getPheromoneVisualization() {
    if (!_initialized) {
      return Container(); // Leerer Container falls nicht initialisiert
    }

    return pheromoneSystem.buildVisualization(
      showTypes: [
        PheromoneType.food,
        PheromoneType.nest,
      ], // Gefahr optional hinzufügen
      opacity: 0.4,
    );
  }

  /// Startet den Bau einer Kammer
  void startChamberConstruction(int chamberId, int workerCount) {
    if (!_initialized) return;

    final chambers = gameProvider.chambers;
    final chamber = chambers.firstWhere(
      (c) => c.id == chamberId,
      orElse: () => null!,
    );

    // Wenn die Kammer existiert und im PLANNED-Zustand ist
    if (chamber != null && chamber.state == ChamberState.PLANNED) {
      final updatedChamber = chamber.startConstruction(
        DateTime.now(),
        workerCount,
      );

      // Aktualisiere die Kammerliste
      final updatedChambers =
          chambers.map((c) {
            return c.id == chamberId ? updatedChamber : c;
          }).toList();

      // Kolonie aktualisieren
      final updatedColony = gameProvider.colony.copyWith(
        chambers: updatedChambers,
      );
      gameProvider.loadColony(updatedColony);

      // Arbeiter der Bauaufgabe zuweisen
      gameProvider.assignAntsToTask('building', workerCount);
    }
  }

  /// Passt die Anzahl der Arbeiter für eine Kammer im Bau an
  void adjustChamberWorkers(int chamberId, int newWorkerCount) {
    if (!_initialized) return;

    final chambers = gameProvider.chambers;
    final chamber = chambers.firstWhere(
      (c) => c.id == chamberId,
      orElse: () => null!,
    );

    // Wenn die Kammer existiert und im BUILDING-Zustand ist
    if (chamber != null && chamber.state == ChamberState.BUILDING) {
      final currentWorkers = chamber.assignedWorkers;
      final workerDiff = newWorkerCount - currentWorkers;

      // Wenn sich die Anzahl ändert
      if (workerDiff != 0) {
        final updatedChamber = chamber.adjustWorkers(
          newWorkerCount,
          DateTime.now(),
        );

        // Aktualisiere die Kammerliste
        final updatedChambers =
            chambers.map((c) {
              return c.id == chamberId ? updatedChamber : c;
            }).toList();

        // Kolonie aktualisieren
        final updatedColony = gameProvider.colony.copyWith(
          chambers: updatedChambers,
        );
        gameProvider.loadColony(updatedColony);

        // Arbeiter anpassen
        if (workerDiff > 0) {
          gameProvider.assignAntsToTask('building', workerDiff);
        } else {
          gameProvider.unassignAntsFromTask('building', -workerDiff);
        }
      }
    }
  }

  /// Aktualisiert den Baufortschritt aller Kammern
  void updateChamberConstructionProgress() {
    if (!_initialized) return;

    final chambers = gameProvider.chambers;
    final now = DateTime.now();
    bool hasChanges = false;

    // Kammerliste aktualisieren
    final updatedChambers =
        chambers.map((chamber) {
          if (chamber.state == ChamberState.BUILDING) {
            final updatedChamber = chamber.updateConstructionProgress(now);

            // Prüfen, ob die Kammer fertiggestellt wurde
            if (updatedChamber.state == ChamberState.COMPLETED &&
                chamber.state == ChamberState.BUILDING) {
              // Arbeiter freigeben
              gameProvider.unassignAntsFromTask(
                'building',
                chamber.assignedWorkers,
              );

              // Benachrichtigung anzeigen
              gameProvider.setNotification(
                'Kammer "${chamber.type}" fertiggestellt!',
              );

              hasChanges = true;
            } else if (updatedChamber.constructionProgress !=
                chamber.constructionProgress) {
              hasChanges = true;
            }

            return updatedChamber;
          }
          return chamber;
        }).toList();

    // Kolonie nur aktualisieren, wenn Änderungen vorliegen
    if (hasChanges) {
      final updatedColony = gameProvider.colony.copyWith(
        chambers: updatedChambers,
      );
      gameProvider.loadColony(updatedColony);
    }
  }

  /// Räumt Ressourcen auf
  void dispose() {
    _eventTimer?.cancel();
    viewManager.dispose();
  }
}
