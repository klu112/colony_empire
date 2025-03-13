/// Verwaltet alle spielrelevanten Ressourcen
class Resources {
  final double food;
  final double buildingMaterials;
  final double water;
  final Map<String, int> population;

  const Resources({
    required this.food,
    required this.buildingMaterials,
    required this.water,
    required this.population,
  });

  Resources copyWith({
    double? food,
    double? buildingMaterials,
    double? water,
    Map<String, int>? population,
  }) {
    return Resources(
      food: food ?? this.food,
      buildingMaterials: buildingMaterials ?? this.buildingMaterials,
      water: water ?? this.water,
      population: population ?? Map.from(this.population),
    );
  }

  factory Resources.initial() {
    return Resources(
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
  }

  factory Resources.fromJson(Map<String, dynamic> json) {
    return Resources(
      food: json['food'] as double,
      buildingMaterials: json['buildingMaterials'] as double,
      water: json['water'] as double,
      population: Map<String, int>.from(json['population'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food': food,
      'buildingMaterials': buildingMaterials,
      'water': water,
      'population': population,
    };
  }

  int get totalPopulation =>
      population.values.fold(0, (sum, count) => sum + count);
}
