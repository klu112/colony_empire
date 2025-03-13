import 'dart:math';
import '../../models/resources/resources_model.dart';
import '../../models/resources/task_allocation_model.dart';

/// Repräsentiert ein Spielereignis
class GameEvent {
  final String message;
  final String type; // 'neutral', 'positive', 'negative'
  final Function effect;

  GameEvent({required this.message, required this.type, required this.effect});
}

/// Service zur Erzeugung und Verwaltung von Spielereignissen
class EventService {
  final Random _random = Random();

  /// Generiert ein zufälliges Ereignis basierend auf Spielzustand
  GameEvent generateRandomEvent({
    required Resources resources,
    required TaskAllocation taskAllocation,
    required String? selectedSpeciesId,
  }) {
    // Liste mit möglichen Ereignissen
    final events = [
      // Verteidigungsereignisse
      GameEvent(
        message: 'Ein feindliches Insekt nähert sich dem Nest!',
        type: 'negative',
        effect: () {
          if (taskAllocation.defense < 10) {
            // Verlust einer Arbeiterin
            final newPopulation = Map<String, int>.from(resources.population);
            if (newPopulation['workers']! > 1) {
              newPopulation['workers'] = newPopulation['workers']! - 1;
              return {
                'resources': resources.copyWith(population: newPopulation),
                'notification': 'Eine Arbeiterin wurde vom Feind getötet!',
              };
            }
          }
          return {
            'notification':
                'Deine Soldaten haben das Nest erfolgreich verteidigt!',
          };
        },
      ),

      // Wettergeschehen
      GameEvent(
        message: 'Es hat angefangen zu regnen.',
        type: 'positive',
        effect: () {
          return {
            'resources': resources.copyWith(
              water: (resources.water + 20).clamp(0.0, 100.0),
            ),
            'notification': 'Der Regen hat deine Wasservorräte aufgefüllt!',
          };
        },
      ),

      // Nahrungsquellen
      GameEvent(
        message: 'Eure Sammler haben eine große Nahrungsquelle gefunden!',
        type: 'positive',
        effect: () {
          return {
            'resources': resources.copyWith(
              food: (resources.food + 15).clamp(0.0, 100.0),
            ),
            'notification': 'Deine Nahrungsvorräte wurden aufgefüllt!',
          };
        },
      ),

      // Feuchtigkeit/Trockenheit
      GameEvent(
        message: 'Eine Trockenperiode hat begonnen.',
        type: 'negative',
        effect: () {
          return {
            'resources': resources.copyWith(
              water: (resources.water - 10).clamp(0.0, 100.0),
            ),
            'notification': 'Deine Wasservorräte sind gesunken!',
          };
        },
      ),

      // Materialfunde
      GameEvent(
        message: 'Arbeiterinnen haben verwertbares Material gefunden.',
        type: 'positive',
        effect: () {
          return {
            'resources': resources.copyWith(
              buildingMaterials: (resources.buildingMaterials + 12).clamp(
                0.0,
                100.0,
              ),
            ),
            'notification': 'Deine Baumaterialien wurden aufgefüllt!',
          };
        },
      ),
    ];

    // Artspezifische Ereignisse hinzufügen
    if (selectedSpeciesId == 'atta') {
      events.add(
        GameEvent(
          message: 'Eure Pilzgärten gedeihen prächtig!',
          type: 'positive',
          effect: () {
            return {
              'resources': resources.copyWith(
                food: (resources.food + 20).clamp(0.0, 100.0),
              ),
              'notification': 'Die Pilze haben zusätzliche Nahrung produziert!',
            };
          },
        ),
      );
    } else if (selectedSpeciesId == 'eciton') {
      events.add(
        GameEvent(
          message: 'Eure Soldaten haben ein feindliches Nest überfallen!',
          type: 'positive',
          effect: () {
            return {
              'resources': resources.copyWith(
                food: (resources.food + 25).clamp(0.0, 100.0),
              ),
              'notification': 'Der Überfall brachte zusätzliche Nahrung ein!',
            };
          },
        ),
      );
    }

    // Zufälliges Ereignis auswählen
    return events[_random.nextInt(events.length)];
  }
}
