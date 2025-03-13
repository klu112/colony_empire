import 'dart:math';
import 'dart:ui';
import '../../models/ant/ant_model.dart';
import '../../models/chamber/chamber_model.dart';
import '../../models/resources/resources_model.dart';
import '../../models/resources/task_allocation_model.dart';
import '../../utils/constants/ant_data.dart';

/// Service zur Verwaltung des Ameisenverhaltens
class AntManagerService {
  final Random _random = Random();

  /// Initialisiere Ameisen für den Spielstart
  List<Ant> initializeAnts(List<Chamber> chambers, Resources resources) {
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
      final targetChamber = chambers[_random.nextInt(chambers.length)];
      final taskList = [
        'foraging',
        'building',
        'caregiving',
        'defense',
        'exploration',
      ];
      final randomTask = taskList[_random.nextInt(taskList.length)];

      initialAnts.add(
        Ant(
          id: i + 2,
          type: 'worker',
          position: chambers[0].position,
          target: targetChamber.position,
          task: randomTask,
          chamberID: _random.nextInt(chambers.length) + 1,
        ),
      );
    }

    return initialAnts;
  }

  /// Aktualisiere Ameisenbewegung und -verhalten
  List<Ant> updateAnts(
    List<Ant> ants,
    List<Chamber> chambers,
    TaskAllocation taskAllocation,
  ) {
    if (ants.isEmpty) return [];

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
        Chamber targetChamber;
        String? task = ant.task;

        // Aufgabenbasierte Zielauswahl
        if (task != null) {
          switch (task) {
            case 'foraging':
              // Nahrungssammler bevorzugen Lager und Außenbereiche
              targetChamber = _getPreferredChamber(chambers, [
                'storage',
                'waste',
              ]);
              break;
            case 'building':
              // Bauarbeiter bevorzugen alle Kammern
              targetChamber = chambers[_random.nextInt(chambers.length)];
              break;
            case 'caregiving':
              // Brutpflegerinnen bevorzugen Brutkammern und Königinnenkammern
              targetChamber = _getPreferredChamber(chambers, [
                'queen',
                'nursery',
              ]);
              break;
            case 'defense':
              // Wächterinnen bevorzugen Verteidigungskammern und Außenbereiche
              targetChamber = _getPreferredChamber(chambers, [
                'defense',
                'waste',
              ]);
              break;
            case 'exploration':
              // Kundschafterinnen bevorzugen Außenbereiche
              targetChamber = _getPreferredChamber(chambers, ['waste']);
              break;
            default:
              targetChamber = chambers[_random.nextInt(chambers.length)];
          }
        } else {
          targetChamber = chambers[_random.nextInt(chambers.length)];
        }

        // Möglichkeit, dass die Ameise ihre Aufgabe ändert
        if (_random.nextDouble() < 0.05) {
          // Wähle neue Aufgabe basierend auf Aufgabenverteilung
          task = _assignRandomTask(taskAllocation);
        }

        updatedAnts.add(
          ant.copyWith(
            target: targetChamber.position,
            chamberID: targetChamber.id,
            task: task,
          ),
        );
      } else {
        // Bewege in Richtung des Ziels
        final typeInfo = AntData.getTypeInfo(ant.type);
        final speed = typeInfo['speed'] as double;

        final vx = (dx / distance) * speed;
        final vy = (dy / distance) * speed;

        updatedAnts.add(
          ant.copyWith(
            position: Point(ant.position.x + vx, ant.position.y + vy),
          ),
        );
      }
    }

    return updatedAnts;
  }

  /// Aufgabe basierend auf aktueller Verteilung zuweisen
  String _assignRandomTask(TaskAllocation taskAllocation) {
    final int total = taskAllocation.total;
    final int randomValue = _random.nextInt(total);

    int cumulativeValue = 0;

    // Foraging
    cumulativeValue += taskAllocation.foraging;
    if (randomValue < cumulativeValue) return 'foraging';

    // Building
    cumulativeValue += taskAllocation.building;
    if (randomValue < cumulativeValue) return 'building';

    // Caregiving
    cumulativeValue += taskAllocation.caregiving;
    if (randomValue < cumulativeValue) return 'caregiving';

    // Defense
    cumulativeValue += taskAllocation.defense;
    if (randomValue < cumulativeValue) return 'defense';

    // Exploration (default)
    return 'exploration';
  }

  /// Bevorzugte Kammer basierend auf Typ finden
  Chamber _getPreferredChamber(
    List<Chamber> chambers,
    List<String> preferredTypes,
  ) {
    final preferredChambers =
        chambers
            .where((chamber) => preferredTypes.contains(chamber.type))
            .toList();

    if (preferredChambers.isNotEmpty) {
      return preferredChambers[_random.nextInt(preferredChambers.length)];
    } else {
      return chambers[_random.nextInt(chambers.length)];
    }
  }
}
