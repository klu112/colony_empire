import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/ant/ant_model.dart';
import '../models/chamber/chamber_model.dart';
import '../models/chamber/tunnel_model.dart';
import '../models/colony_model.dart';
import '../models/resources/resources_model.dart';
import '../models/resources/task_allocation_model.dart';
import '../services/events/event_service.dart';
import '../utils/constants/game_enums.dart';
import '../utils/constants/species_data.dart';
import 'services_provider.dart';

class GameProvider with ChangeNotifier {
  // Services
  final EventService _eventService = EventService();
  ServicesProvider? _servicesProvider;

  // Spielzustände
  GameState _gameState = GameState.selection;
  String? _selectedSpeciesId;

  // Kolonie-Daten
  Colony _colony = Colony.initial();

  // Hilfsvariablen für UI
  int? _selectedChamberId;
  String? _notification;

  // Neue Variablen für das Aufgabensystem
  /// Map zur Verfolgung der Anzahl von Ameisen pro Aufgabe
  final Map<String, int> _antsPerTask = {
    'foraging': 0,
    'building': 0,
    'caregiving': 0,
    'defense': 0,
    'exploration': 0,
    'unassigned': 0, // Neue Kategorie: Nicht zugewiesene Ameisen
  };

  // Getter
  GameState get gameState => _gameState;
  String? get selectedSpeciesId => _selectedSpeciesId;
  Colony get colony => _colony;
  Resources get resources => _colony.resources;
  TaskAllocation get taskAllocation => _colony.taskAllocation;
  List<Chamber> get chambers => _colony.chambers;
  List<Tunnel> get tunnels => _colony.tunnels;
  List<Ant> get ants => _colony.ants;
  int get time => _colony.time;
  int get speed => _colony.speed;
  int? get selectedChamberId => _selectedChamberId;
  String? get notification => _notification;

  /// Getter für die Anzahl der Ameisen pro Aufgabe
  Map<String, int> get antsPerTask => Map.unmodifiable(_antsPerTask);

  /// Anzahl nicht zugewiesener Ameisen
  int get unassignedAnts => _antsPerTask['unassigned'] ?? 0;

  /// Gesamtanzahl der Arbeiterameisen
  int get totalWorkerAnts {
    final workerCount = resources.population['workers'] ?? 0;
    return workerCount;
  }

  // Setter
  void setGameState(GameState newState) {
    print("Ändere GameState von $_gameState zu $newState");
    _gameState = newState;

    // Wenn der Zustand auf Playing wechselt, starte den Game Loop
    if (newState == GameState.playing &&
        _servicesProvider != null &&
        _servicesProvider!.initialized) {
      print("Starte GameLoop wegen GameState-Änderung zu Playing");
      _servicesProvider!.gameLoopService.setSpeed(_colony.speed);
    }

    notifyListeners();
  }

  // Für Kompatibilität mit bisherigem Code
  void setGameStateFromString(String stateString) {
    setGameState(GameStateExtension.fromString(stateString));
  }

  void setSelectedSpecies(String speciesId) {
    _selectedSpeciesId = speciesId;
    _colony = _colony.copyWith(selectedSpeciesId: speciesId);
    notifyListeners();
  }

  void setSpeed(int newSpeed) {
    _colony = _colony.copyWith(speed: newSpeed);

    // Geschwindigkeit auch im GameLoopService aktualisieren
    if (_servicesProvider != null && _servicesProvider!.initialized) {
      _servicesProvider!.setGameSpeed(newSpeed);
    }

    notifyListeners();
  }

  void selectChamber(int? chamberId) {
    _selectedChamberId = chamberId;
    notifyListeners();
  }

  void setNotification(String? message) {
    _notification = message;
    notifyListeners();

    if (message != null) {
      // Benachrichtigung nach einiger Zeit automatisch ausblenden
      Future.delayed(const Duration(seconds: 5), () {
        if (_notification == message) {
          _notification = null;
          notifyListeners();
        }
      });
    }
  }

  // Aufgabenzuweisung
  void updateTaskAllocation(String task, int value) {
    // Berechne Gesamtprozentsatz ohne die aktuelle Aufgabe
    final Map<String, int> current = {
      'foraging': taskAllocation.foraging,
      'building': taskAllocation.building,
      'caregiving': taskAllocation.caregiving,
      'defense': taskAllocation.defense,
      'exploration': taskAllocation.exploration,
    };

    final int otherTasksTotal = current.entries
        .where((entry) => entry.key != task)
        .fold(0, (sum, entry) => sum + entry.value);

    // Stelle sicher, dass wir 100% nicht überschreiten
    final int newValue = value.clamp(0, 95);

    if (otherTasksTotal + newValue > 100) {
      // Skaliere andere Aufgaben proportional herunter
      final double scale = (100 - newValue) / otherTasksTotal;

      final Map<String, int> adjusted = {};
      for (final entry in current.entries) {
        if (entry.key == task) {
          adjusted[entry.key] = newValue;
        } else {
          adjusted[entry.key] = (entry.value * scale).round();
        }
      }

      _colony = _colony.copyWith(
        taskAllocation: TaskAllocation(
          foraging: adjusted['foraging']!,
          building: adjusted['building']!,
          caregiving: adjusted['caregiving']!,
          defense: adjusted['defense']!,
          exploration: adjusted['exploration']!,
        ),
      );
    } else {
      // Aktualisiere nur die eine Aufgabe
      final TaskAllocation newAllocation;

      switch (task) {
        case 'foraging':
          newAllocation = taskAllocation.copyWith(foraging: newValue);
          break;
        case 'building':
          newAllocation = taskAllocation.copyWith(building: newValue);
          break;
        case 'caregiving':
          newAllocation = taskAllocation.copyWith(caregiving: newValue);
          break;
        case 'defense':
          newAllocation = taskAllocation.copyWith(defense: newValue);
          break;
        case 'exploration':
          newAllocation = taskAllocation.copyWith(exploration: newValue);
          break;
        default:
          return;
      }

      _colony = _colony.copyWith(taskAllocation: newAllocation);
    }

    // Aktualisiere die tatsächlichen Ameisenzuweisungen entsprechend der neuen Prozentsätze
    _redistributeAntsBasedOnTaskAllocation();

    notifyListeners();
  }

  /// Weist Ameisen basierend auf den Prozentangaben der TaskAllocation zu
  void _redistributeAntsBasedOnTaskAllocation() {
    final int totalWorkers = totalWorkerAnts;

    // Berechne die Zielanzahl für jede Aufgabe
    final Map<String, int> targetAntsPerTask = {
      'foraging': (totalWorkers * taskAllocation.foraging / 100).round(),
      'building': (totalWorkers * taskAllocation.building / 100).round(),
      'caregiving': (totalWorkers * taskAllocation.caregiving / 100).round(),
      'defense': (totalWorkers * taskAllocation.defense / 100).round(),
      'exploration': (totalWorkers * taskAllocation.exploration / 100).round(),
    };

    // Finde Ameisen, die umverteilt werden müssen
    final List<Ant> antsToRedistribute = [];
    final List<Ant> newAnts = [];

    // Aktualisiere die Ameisenobjekte
    for (final ant in ants) {
      if (ant.type != 'worker')
        continue; // Ignoriere nicht-Arbeiter (z.B. Königin)

      // Überprüfe, ob die Aufgabe der Ameise überzugewiesen ist
      final String task = ant.task ?? 'unassigned';
      if (task != 'unassigned' &&
          (_antsPerTask[task]! > targetAntsPerTask[task]! ||
              !targetAntsPerTask.containsKey(task))) {
        antsToRedistribute.add(ant);
      } else {
        newAnts.add(ant);
      }
    }

    // Unterbesetzung füllen
    for (final taskEntry in targetAntsPerTask.entries) {
      final String task = taskEntry.key;
      final int targetCount = taskEntry.value;

      // Zähle, wie viele Ameisen wir bereits für diese Aufgabe haben
      int currentCount = newAnts.where((ant) => ant.task == task).length;

      // Füge weitere Ameisen hinzu, bis wir die Zielanzahl erreichen
      while (currentCount < targetCount && antsToRedistribute.isNotEmpty) {
        final ant = antsToRedistribute.removeAt(0);
        newAnts.add(ant.copyWith(task: task));
        currentCount++;
      }
    }

    // Verbleibende Ameisen als nicht zugewiesen markieren
    for (final ant in antsToRedistribute) {
      newAnts.add(ant.copyWith(task: 'unassigned'));
    }

    // Aktualisiere die Kolonie mit den neuen Ameisenzuweisungen
    _colony = _colony.copyWith(ants: newAnts);

    // Aktualisiere die Zähler für Ameisen pro Aufgabe
    _updateAntsPerTaskCount();
  }

  /// Aktualisiert die Zähler für Ameisen pro Aufgabe
  void _updateAntsPerTaskCount() {
    // Zurücksetzen der Zähler
    _antsPerTask.forEach((task, _) => _antsPerTask[task] = 0);

    // Zählen der Ameisen pro Aufgabe
    for (final ant in ants) {
      if (ant.type != 'worker') continue;

      final String task = ant.task ?? 'unassigned';
      _antsPerTask[task] = (_antsPerTask[task] ?? 0) + 1;
    }
  }

  /// Weist eine bestimmte Anzahl von Ameisen einer Aufgabe zu
  /// Gibt die tatsächlich zugewiesene Anzahl zurück
  int assignAntsToTask(String task, int count) {
    if (!_antsPerTask.containsKey(task) || count <= 0) return 0;

    // Überprüfe, wie viele nicht zugewiesene Ameisen verfügbar sind
    final int available = _antsPerTask['unassigned'] ?? 0;
    final int toAssign = min(count, available);

    if (toAssign <= 0) return 0;

    // Finde nicht zugewiesene Ameisen
    final List<Ant> unassignedAnts =
        ants
            .where(
              (ant) =>
                  ant.type == 'worker' &&
                  (ant.task == null || ant.task == 'unassigned'),
            )
            .toList();

    if (unassignedAnts.isEmpty) return 0;

    // Aktualisiere die Ameisenobjekte
    final List<Ant> updatedAnts = List.of(ants);

    for (int i = 0; i < min(toAssign, unassignedAnts.length); i++) {
      final int antIndex = updatedAnts.indexOf(unassignedAnts[i]);
      if (antIndex >= 0) {
        updatedAnts[antIndex] = unassignedAnts[i].copyWith(task: task);
      }
    }

    // Aktualisiere die Kolonie
    _colony = _colony.copyWith(ants: updatedAnts);

    // Aktualisiere die Zähler
    _updateAntsPerTaskCount();

    // Aktualisiere TaskAllocation entsprechend
    _updateTaskAllocationFromAntCounts();

    notifyListeners();
    return toAssign;
  }

  /// Entfernt eine bestimmte Anzahl von Ameisen von einer Aufgabe
  /// Gibt die tatsächlich entfernte Anzahl zurück
  int unassignAntsFromTask(String task, int count) {
    if (!_antsPerTask.containsKey(task) || count <= 0) return 0;

    // Überprüfe, wie viele Ameisen dieser Aufgabe zugewiesen sind
    final int assigned = _antsPerTask[task] ?? 0;
    final int toUnassign = min(count, assigned);

    if (toUnassign <= 0) return 0;

    // Finde Ameisen, die dieser Aufgabe zugewiesen sind
    final List<Ant> taskAnts =
        ants.where((ant) => ant.type == 'worker' && ant.task == task).toList();

    if (taskAnts.isEmpty) return 0;

    // Aktualisiere die Ameisenobjekte
    final List<Ant> updatedAnts = List.of(ants);

    for (int i = 0; i < min(toUnassign, taskAnts.length); i++) {
      final int antIndex = updatedAnts.indexOf(taskAnts[i]);
      if (antIndex >= 0) {
        updatedAnts[antIndex] = taskAnts[i].copyWith(task: 'unassigned');
      }
    }

    // Aktualisiere die Kolonie
    _colony = _colony.copyWith(ants: updatedAnts);

    // Aktualisiere die Zähler
    _updateAntsPerTaskCount();

    // Aktualisiere TaskAllocation entsprechend
    _updateTaskAllocationFromAntCounts();

    notifyListeners();
    return toUnassign;
  }

  /// Aktualisiert die TaskAllocation basierend auf den tatsächlichen Ameisenzahlen
  void _updateTaskAllocationFromAntCounts() {
    final int totalWorkers = totalWorkerAnts;
    if (totalWorkers <= 0) return;

    // Berechne die Prozentwerte basierend auf den tatsächlichen Zahlen
    final TaskAllocation newAllocation = TaskAllocation(
      foraging:
          (((_antsPerTask['foraging'] ?? 0) / totalWorkers) * 100).round(),
      building:
          (((_antsPerTask['building'] ?? 0) / totalWorkers) * 100).round(),
      caregiving:
          (((_antsPerTask['caregiving'] ?? 0) / totalWorkers) * 100).round(),
      defense: (((_antsPerTask['defense'] ?? 0) / totalWorkers) * 100).round(),
      exploration:
          (((_antsPerTask['exploration'] ?? 0) / totalWorkers) * 100).round(),
    );

    _colony = _colony.copyWith(taskAllocation: newAllocation);
  }

  // Neue Kammer hinzufügen
  void addChamber(String type) {
    // Prüfe Ressourcen
    final chamberCost = 20.0; // Später aus ChamberData holen

    if (resources.buildingMaterials < chamberCost) {
      setNotification('Nicht genügend Baumaterial!');
      return;
    }

    // Neue Kammer erstellen
    final newChamber = Chamber(
      id: chambers.length + 1,
      type: type,
      size: 1,
      position: Point(
        150 + (Random().nextDouble() * 100 - 50),
        150 + (Random().nextDouble() * 100 - 50),
      ),
    );

    // Neuen Tunnel erstellen
    final newTunnel = Tunnel(
      from: chambers[0].id, // Von der Königinnenkammer
      to: newChamber.id,
    );

    // Ressourcen aktualisieren
    final newResources = resources.copyWith(
      buildingMaterials: resources.buildingMaterials - chamberCost,
    );

    // Kolonie aktualisieren
    _colony = _colony.copyWith(
      chambers: [...chambers, newChamber],
      tunnels: [...tunnels, newTunnel],
      resources: newResources,
    );

    notifyListeners();
  }

  // Spielzeit aktualisieren
  void updateTime() {
    _colony = _colony.copyWith(time: time + 1);
    notifyListeners();
  }

  // Ressourcen aktualisieren basierend auf Aufgabenverteilung
  void updateResources() {
    // Spezies-Bonus ermitteln
    final foodBonus = _selectedSpeciesId == 'atta' ? 1.5 : 1.0;
    final foodChange = taskAllocation.foraging / 25 * foodBonus;
    final materialChange = taskAllocation.building / 40;
    final waterChange = taskAllocation.foraging / 50;

    // Populationsänderungen berechnen
    final Map<String, int> newPopulation = Map.from(resources.population);

    // Alle 10 Ticks Chance auf Eierschlupf basierend auf Brutpflege
    if (time % 10 == 0) {
      final hatchChance = taskAllocation.caregiving / 100;
      if (Random().nextDouble() < hatchChance && newPopulation['eggs']! > 0) {
        newPopulation['eggs'] = newPopulation['eggs']! - 1;
        newPopulation['larvae'] = newPopulation['larvae']! + 1;
      }

      if (Random().nextDouble() < hatchChance && newPopulation['larvae']! > 0) {
        newPopulation['larvae'] = newPopulation['larvae']! - 1;
        newPopulation['workers'] = newPopulation['workers']! + 1;

        // Neue Ameise als nicht zugewiesen markieren
        _antsPerTask['unassigned'] = (_antsPerTask['unassigned'] ?? 0) + 1;
      }

      // Königin legt Eier basierend auf Nahrung
      if (resources.food > 20 && time % 20 == 0) {
        newPopulation['eggs'] = newPopulation['eggs']! + 1;

        // Bonus für Feuerameisen
        if (_selectedSpeciesId == 'solenopsis') {
          newPopulation['eggs'] = newPopulation['eggs']! + 1;
        }
      }
    }

    // Aktualisiere Ressourcen
    final newResources = resources.copyWith(
      food: (resources.food + foodChange - (newPopulation['workers']! * 0.05))
          .clamp(0.0, 100.0),
      buildingMaterials: (resources.buildingMaterials + materialChange).clamp(
        0.0,
        100.0,
      ),
      water: (resources.water + waterChange - 0.1).clamp(0.0, 100.0),
      population: newPopulation,
    );

    _colony = _colony.copyWith(resources: newResources);

    // Wenn sich die Anzahl der Arbeiter geändert hat, stelle sicher,
    // dass die Aufgabenverteilung aktualisiert wird
    if (newPopulation['workers'] != resources.population['workers']) {
      _initializeNewAnts(
        newPopulation['workers']! - resources.population['workers']!,
      );
    }

    notifyListeners();
  }

  /// Initialisiert neue Ameisen und fügt sie zum unassigned Pool hinzu
  void _initializeNewAnts(int count) {
    if (count <= 0) return;

    // Erstelle neue Ameisen
    final List<Ant> newAnts = List.of(ants);
    final int startId =
        newAnts.isNotEmpty ? newAnts.map((a) => a.id).reduce(max) + 1 : 1;

    for (int i = 0; i < count; i++) {
      // Zufällige Position in einer zufälligen Kammer
      final targetChamber = chambers[Random().nextInt(chambers.length)];

      newAnts.add(
        Ant(
          id: startId + i,
          type: 'worker',
          position: Point(
            targetChamber.position.x + (Random().nextDouble() * 20 - 10),
            targetChamber.position.y + (Random().nextDouble() * 20 - 10),
          ),
          target: targetChamber.position,
          task: 'unassigned', // Neue Ameisen starten als nicht zugewiesen
          chamberID: targetChamber.id,
        ),
      );
    }

    // Aktualisiere die Kolonie
    _colony = _colony.copyWith(ants: newAnts);

    // Aktualisiere die Zähler
    _updateAntsPerTaskCount();
  }

  // Ameisen bewegen
  void updateAnts() {
    // Initialisiere Ameisen, wenn noch keine vorhanden sind
    if (ants.isEmpty && _gameState == GameState.playing) {
      _initializeAnts();
      return;
    }

    final List<Ant> updatedAnts = [];

    for (final ant in ants) {
      // Königin bewegt sich nicht
      if (ant.type == 'queen') {
        updatedAnts.add(ant);
        continue;
      }

      // Bewegung berechnen
      final dx = ant.target.x - ant.position.x;
      final dy = ant.target.y - ant.position.y;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < 2) {
        // Ziel erreicht, neues Ziel setzen
        final targetChamber = chambers[Random().nextInt(chambers.length)];
        updatedAnts.add(
          ant.copyWith(
            target: targetChamber.position,
            chamberID: targetChamber.id,
          ),
        );
      } else {
        // Bewege in Richtung des Ziels
        final speed = 2.0;
        final vx = (dx / distance) * speed;
        final vy = (dy / distance) * speed;

        updatedAnts.add(
          ant.copyWith(
            position: Point(ant.position.x + vx, ant.position.y + vy),
          ),
        );
      }
    }

    _colony = _colony.copyWith(ants: updatedAnts);
    notifyListeners();
  }

  // Initialisiere Ameisen für den Spielstart
  void _initializeAnts() {
    final List<Ant> initialAnts = [];

    // Königin hinzufügen
    initialAnts.add(
      Ant(
        id: 1,
        type: 'queen',
        position: chambers[0].position,
        target: chambers[0].position,
        chamberID: chambers[0].id,
      ),
    );

    // Initialen Arbeiterinnen hinzufügen
    for (int i = 0; i < resources.population['workers']!; i++) {
      final targetChamber = chambers[Random().nextInt(chambers.length)];

      // Zufällige Aufgabe zuweisen (oder unassigned lassen)
      String? taskAssignment;
      final assignChance = Random().nextDouble();

      if (assignChance < 0.7) {
        // 70% Chance auf eine Aufgabe
        final tasks = [
          'foraging',
          'building',
          'caregiving',
          'defense',
          'exploration',
        ];
        taskAssignment = tasks[Random().nextInt(tasks.length)];
      } else {
        taskAssignment = 'unassigned'; // 30% Chance, nicht zugewiesen zu sein
      }

      initialAnts.add(
        Ant(
          id: i + 2,
          type: 'worker',
          position: chambers[0].position,
          target: targetChamber.position,
          task: taskAssignment,
          chamberID: Random().nextInt(chambers.length) + 1,
        ),
      );
    }

    _colony = _colony.copyWith(ants: initialAnts);

    // Aktualisiere die antsPerTask Map
    _updateAntsPerTaskCount();

    // Aktualisiere die TaskAllocation based on initial assignments
    _updateTaskAllocationFromAntCounts();

    notifyListeners();
  }

  // Zufallsereignis auslösen mit EventService
  void triggerRandomEvent() {
    final randomEvent = _eventService.generateRandomEvent(
      resources: resources,
      taskAllocation: taskAllocation,
      selectedSpeciesId: _selectedSpeciesId,
    );

    // Effekt anwenden
    final effectResult = randomEvent.effect();

    // Ressourcen aktualisieren, falls vorhanden
    if (effectResult.containsKey('resources')) {
      _colony = _colony.copyWith(
        resources: effectResult['resources'] as Resources,
      );
    }

    // Benachrichtigung anzeigen
    if (effectResult.containsKey('notification')) {
      setNotification(effectResult['notification'] as String);
    } else {
      setNotification(randomEvent.message);
    }
  }

  /// Aktualisiert Ressourcen von externem Service
  void updateResourcesFromService(Resources updatedResources) {
    _colony = _colony.copyWith(resources: updatedResources);
    notifyListeners();
  }

  /// Aktualisiert Ameisen von externem Service
  void updateAntsFromService(List<Ant> updatedAnts) {
    _colony = _colony.copyWith(ants: updatedAnts);

    // Auch die Zähler aktualisieren
    _updateAntsPerTaskCount();

    notifyListeners();
  }

  /// Lade eine gespeicherte Kolonie
  void loadColony(Colony savedColony) {
    _colony = savedColony;
    _gameState = GameState.playing;
    _selectedSpeciesId = savedColony.selectedSpeciesId;

    // Zähler für Ameisen pro Aufgabe aktualisieren
    _updateAntsPerTaskCount();

    notifyListeners();
  }

  /// Aktualisiere den ServicesProvider
  void updateServicesProvider(ServicesProvider servicesProvider) {
    _servicesProvider = servicesProvider;

    // Wenn Services noch nicht initialisiert sind, initialisieren wir sie nicht hier
    if (!servicesProvider.initialized) {
      print(
        "ServicesProvider noch nicht initialisiert in updateServicesProvider",
      );
      return;
    }

    // Wenn der GameState bereits Playing ist, starte den GameLoop
    if (_gameState == GameState.playing) {
      print("Starte GameLoop weil GameState bereits auf Playing ist");
      _servicesProvider!.gameLoopService.setSpeed(_colony.speed);
    }
  }
}
