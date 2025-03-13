import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/ant/ant_model.dart';
import '../models/chamber/chamber_model.dart';
import '../models/chamber/tunnel_model.dart';
import '../models/colony_model.dart';
import '../models/resources/resources_model.dart';
import '../models/resources/task_allocation_model.dart';
import '../utils/constants/species_data.dart';
// Importiere math für Random
import 'dart:math' as math;

class GameProvider with ChangeNotifier {
  // Spielzustände: selection, tutorial, playing, paused
  String _gameState = 'selection';
  String? _selectedSpeciesId;

  // Kolonie-Daten
  Colony _colony = Colony.initial();

  // Hilfsvariablen für UI
  int? _selectedChamberId;
  String? _notification;

  // Getter
  String get gameState => _gameState;
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

  // Setter
  void setGameState(String newState) {
    _gameState = newState;
    notifyListeners();
  }

  void setSelectedSpecies(String speciesId) {
    _selectedSpeciesId = speciesId;
    _colony = _colony.copyWith(selectedSpeciesId: speciesId);
    notifyListeners();
  }

  void setSpeed(int newSpeed) {
    _colony = _colony.copyWith(speed: newSpeed);
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

    notifyListeners();
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
        150 + (math.Random().nextDouble() * 100 - 50),
        150 + (math.Random().nextDouble() * 100 - 50),
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
    // Diese Logik wird später detaillierter im GameLoop implementiert
    final foodBonus = _selectedSpeciesId == 'atta' ? 1.5 : 1.0;
    final foodChange = taskAllocation.foraging / 25 * foodBonus;
    final materialChange = taskAllocation.building / 40;
    final waterChange = taskAllocation.foraging / 50;

    // Populationsänderungen berechnen
    final Map<String, int> newPopulation = Map.from(resources.population);

    // Alle 10 Ticks Chance auf Eierschlupf basierend auf Brutpflege
    if (time % 10 == 0) {
      final hatchChance = taskAllocation.caregiving / 100;
      if (math.Random().nextDouble() < hatchChance &&
          newPopulation['eggs']! > 0) {
        newPopulation['eggs'] = newPopulation['eggs']! - 1;
        newPopulation['larvae'] = newPopulation['larvae']! + 1;
      }

      if (math.Random().nextDouble() < hatchChance &&
          newPopulation['larvae']! > 0) {
        newPopulation['larvae'] = newPopulation['larvae']! - 1;
        newPopulation['workers'] = newPopulation['workers']! + 1;
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
    notifyListeners();
  }

  // Ameisen bewegen
  void updateAnts() {
    // Diese Logik wird später detaillierter im GameLoop implementiert
    if (ants.isEmpty && _gameState == 'playing') {
      // Initialisiere Ameisen, wenn noch keine vorhanden sind
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
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance < 2) {
        // Ziel erreicht, neues Ziel setzen
        final targetChamber = chambers[math.Random().nextInt(chambers.length)];
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
      final targetChamber = chambers[math.Random().nextInt(chambers.length)];
      final taskList = [
        'foraging',
        'building',
        'caregiving',
        'defense',
        'exploration',
      ];
      final randomTask = taskList[math.Random().nextInt(taskList.length)];

      initialAnts.add(
        Ant(
          id: i + 2,
          type: 'worker',
          position: chambers[0].position,
          target: targetChamber.position,
          task: randomTask,
          chamberID: math.Random().nextInt(chambers.length) + 1,
        ),
      );
    }

    _colony = _colony.copyWith(ants: initialAnts);
    notifyListeners();
  }

  // Zufallsereignis auslösen
  void triggerRandomEvent() {
    final events = [
      {
        'message': 'Ein feindliches Insekt nähert sich dem Nest!',
        'effect': () {
          if (taskAllocation.defense < 10) {
            // Verlust einer Arbeiterin
            final Map<String, int> newPopulation = Map<String, int>.from(
              resources.population,
            );
            if (newPopulation['workers']! > 1) {
              newPopulation['workers'] = newPopulation['workers']! - 1;

              _colony = _colony.copyWith(
                resources: resources.copyWith(population: newPopulation),
              );

              setNotification('Eine Arbeiterin wurde vom Feind getötet!');
            }
          } else {
            setNotification(
              'Deine Soldaten haben das Nest erfolgreich verteidigt!',
            );
          }
        },
      },
      {
        'message': 'Es hat angefangen zu regnen.',
        'effect': () {
          _colony = _colony.copyWith(
            resources: resources.copyWith(
              water: (resources.water + 20).clamp(0.0, 100.0),
            ),
          );
          setNotification('Der Regen hat deine Wasservorräte aufgefüllt!');
        },
      },
      {
        'message': 'Eure Sammler haben eine große Nahrungsquelle gefunden!',
        'effect': () {
          _colony = _colony.copyWith(
            resources: resources.copyWith(
              food: (resources.food + 15).clamp(0.0, 100.0),
            ),
          );
          setNotification('Deine Nahrungsvorräte wurden aufgefüllt!');
        },
      },
    ];

    final randomEvent = events[math.Random().nextInt(events.length)];
    setNotification(randomEvent['message'] as String);
    (randomEvent['effect'] as Function)();
  }
}
