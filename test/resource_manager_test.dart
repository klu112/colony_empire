import 'package:flutter_test/flutter_test.dart';
import 'package:colony_empire/models/resources/resources_model.dart';
import 'package:colony_empire/models/resources/task_allocation_model.dart';
import 'package:colony_empire/services/game_loop/resource_manager_service.dart';

void main() {
  group('ResourceManagerService', () {
    late ResourceManagerService resourceManager;

    setUp(() {
      resourceManager = ResourceManagerService();
    });

    test('calculates food change correctly', () {
      final taskAllocation = TaskAllocation(
        foraging: 50,
        building: 20,
        caregiving: 20,
        defense: 5,
        exploration: 5,
      );

      final normalFoodChange = resourceManager.calculateFoodChange(
        taskAllocation,
        1.0,
      );
      final attaFoodChange = resourceManager.calculateFoodChange(
        taskAllocation,
        1.5,
      );

      expect(normalFoodChange, equals(50 / 25));
      expect(attaFoodChange, equals(50 / 25 * 1.5));
    });

    test('updates resources correctly', () {
      final initialResources = Resources(
        food: 50,
        buildingMaterials: 30,
        water: 40,
        population: {
          'queen': 1,
          'workers': 5,
          'soldiers': 0,
          'scouts': 0,
          'larvae': 3,
          'eggs': 5,
        },
      );

      final taskAllocation = TaskAllocation(
        foraging: 50,
        building: 20,
        caregiving: 20,
        defense: 5,
        exploration: 5,
      );

      final updatedResources = resourceManager.updateResources(
        currentResources: initialResources,
        taskAllocation: taskAllocation,
        selectedSpeciesId: null,
        time: 1, // Nicht teilbar durch 10, keine Entwicklung
      );

      // Überprüfe, ob Ressourcen aktualisiert wurden
      expect(updatedResources.food, isNot(equals(initialResources.food)));
      expect(
        updatedResources.buildingMaterials,
        isNot(equals(initialResources.buildingMaterials)),
      );
      expect(updatedResources.water, isNot(equals(initialResources.water)));

      // Prüfe, ob Population gleichgeblieben ist (weil time nicht % 10 == 0)
      expect(updatedResources.population, equals(initialResources.population));
    });
  });
}
