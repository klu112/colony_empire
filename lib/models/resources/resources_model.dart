import 'dart:math';

/// Repräsentiert alle Ressourcen der Kolonie
class Resources {
  /// Nahrung (0-100)
  final double food;

  /// Baumaterialien (0-100)
  final double buildingMaterials;

  /// Wasser (0-100)
  final double water;

  /// Populationszähler (Eier, Larven, Arbeiterinnen, etc.)
  final Map<String, int> population;

  /// Nahrungszustand der Königin (0-100%)
  /// 100% = volle Energie, 0% = verhungert
  final double queenHealth;

  /// Hungerindex der Kolonie (0-100%)
  /// 0% = keine Hungersnot, 100% = schwere Hungersnot
  final double colonyHunger;

  /// Erstellt eine neue Resources-Instanz
  Resources({
    this.food = 0,
    this.buildingMaterials = 0,
    this.water = 0,
    Map<String, int>? population,
    this.queenHealth = 100.0,
    this.colonyHunger = 0.0,
  }) : population =
           population ??
           {
             'eggs': 0,
             'larvae': 0,
             'pupae': 0,
             'workers': 0,
             'soldiers': 0,
             'queens': 1,
           };

  /// Erstellt eine Kopie mit aktualisierten Werten
  Resources copyWith({
    double? food,
    double? buildingMaterials,
    double? water,
    Map<String, int>? population,
    double? queenHealth,
    double? colonyHunger,
  }) {
    return Resources(
      food: food ?? this.food,
      buildingMaterials: buildingMaterials ?? this.buildingMaterials,
      water: water ?? this.water,
      population: population ?? Map.from(this.population),
      queenHealth: queenHealth ?? this.queenHealth,
      colonyHunger: colonyHunger ?? this.colonyHunger,
    );
  }

  /// Berechnet die Gesamtpopulation der Kolonie
  int get totalPopulation {
    return population.values.fold(0, (sum, count) => sum + count);
  }

  /// Berechnet den täglichen Nahrungsbedarf der Kolonie
  double get dailyFoodRequirement {
    final workerCount = population['workers'] ?? 0;
    final soldierCount = population['soldiers'] ?? 0;
    final larvaeCount = population['larvae'] ?? 0;
    final eggCount = population['eggs'] ?? 0;

    // Bedarfsberechnung je nach Entwicklungsstadium
    return (workerCount * 0.1) +
        (soldierCount * 0.15) +
        (larvaeCount * 0.05) +
        (eggCount * 0.01) +
        0.2; // Königin braucht 0.2
  }

  /// Berechnet den aktuellen Nahrungsmangel-Status
  /// Gibt einen Wert zwischen 0 (kein Mangel) und 1 (vollständiger Mangel) zurück
  double calculateFoodShortage() {
    final requirement = dailyFoodRequirement;

    // Wenn genug oder mehr als genug Nahrung vorhanden ist, gibt es keinen Mangel
    if (food >= requirement) return 0.0;

    // Sonst berechne den relativen Mangel
    return 1.0 - (food / requirement).clamp(0.0, 1.0);
  }

  /// Berechnet die Arbeitseffizienz basierend auf dem Nahrungszustand
  /// Gibt einen Multiplikator zurück (0.5-1.0)
  double calculateWorkEfficiency() {
    // Hunger reduziert die Effizienz (max. 50% Reduktion)
    final hungerPenalty = colonyHunger * 0.5;
    return (1.0 - hungerPenalty).clamp(0.5, 1.0);
  }

  /// Aktualisiert die Ressourcen basierend auf dem Nahrungsverbrauch und -produktion
  Resources updateFoodConsumption(double foodProduction) {
    final requirement = dailyFoodRequirement;
    final availableFood = this.food + foodProduction;

    // Berechne den aktualisierten Nahrungsstand
    final newFood = max(0.0, availableFood - requirement);

    // Berechne den neuen Hungerindex
    double newColonyHunger = this.colonyHunger;
    double newQueenHealth = this.queenHealth;

    if (availableFood >= requirement) {
      // Hunger nimmt ab, wenn genug Nahrung da ist
      newColonyHunger = max(0.0, colonyHunger - 5.0);

      // Königin erholt sich langsam
      newQueenHealth = min(100.0, queenHealth + 2.0);
    } else {
      // Hunger steigt, wenn Nahrungsmangel herrscht
      final shortageRatio = 1.0 - (availableFood / requirement);
      newColonyHunger = min(100.0, colonyHunger + (shortageRatio * 10.0));

      // Königin leidet bei Nahrungsmangel
      newQueenHealth = max(0.0, queenHealth - (shortageRatio * 5.0));
    }

    return copyWith(
      food: newFood,
      colonyHunger: newColonyHunger,
      queenHealth: newQueenHealth,
    );
  }

  /// Berechnet Sterblichkeit aufgrund von Nahrungsmangel
  /// Gibt die Anzahl der sterbenden Ameisen je Kategorie zurück
  Map<String, int> calculateMortality() {
    // Keine Sterblichkeit bei niedrigem Hunger
    if (colonyHunger < 50) {
      return {'workers': 0, 'soldiers': 0, 'larvae': 0, 'eggs': 0};
    }

    // Berechne Sterblichkeitsraten basierend auf Hungerintensität
    final severeHunger = (colonyHunger - 50) / 50; // 0-1 für Hunger 50-100%
    final random = Random();

    // Verschiedene Kastenmitglieder haben unterschiedliche Überlebenschancen
    final workerMortality =
        severeHunger * 0.1; // max 10% der Arbeiter sterben pro Tick
    final soldierMortality = severeHunger * 0.05; // max 5% der Soldaten
    final larvaeMortality = severeHunger * 0.15; // max 15% der Larven
    final eggMortality = severeHunger * 0.2; // max 20% der Eier

    // Berechne absolute Anzahlen
    return {
      'workers':
          (population['workers']! * workerMortality * random.nextDouble())
              .floor(),
      'soldiers':
          (population['soldiers']! * soldierMortality * random.nextDouble())
              .floor(),
      'larvae':
          (population['larvae']! * larvaeMortality * random.nextDouble())
              .floor(),
      'eggs':
          (population['eggs']! * eggMortality * random.nextDouble()).floor(),
    };
  }

  /// Wendet die berechnete Sterblichkeit auf die Population an
  Resources applyMortality() {
    if (colonyHunger < 50) return this;

    final mortality = calculateMortality();
    final newPopulation = Map<String, int>.from(population);

    // Reduziere Populationen basierend auf Sterblichkeit
    mortality.forEach((type, count) {
      if (newPopulation.containsKey(type)) {
        newPopulation[type] = max(0, newPopulation[type]! - count);
      }
    });

    return copyWith(population: newPopulation);
  }

  /// Prüft, ob die Königin verhungert ist
  bool isQueenStarving() => queenHealth <= 25;

  /// Prüft, ob die Königin gestorben ist
  bool isQueenDead() => queenHealth <= 0;

  /// Wandelt die Ressourcen in eine Map für Serialisierung um
  Map<String, dynamic> toJson() {
    return {
      'food': food,
      'buildingMaterials': buildingMaterials,
      'water': water,
      'population': population,
      'queenHealth': queenHealth,
      'colonyHunger': colonyHunger,
    };
  }

  /// Erstellt eine Resources-Instanz aus einer Map (Deserialisierung)
  factory Resources.fromJson(Map<String, dynamic> json) {
    return Resources(
      food: json['food'],
      buildingMaterials: json['buildingMaterials'],
      water: json['water'],
      population: Map<String, int>.from(json['population']),
      queenHealth: json['queenHealth'] ?? 100.0,
      colonyHunger: json['colonyHunger'] ?? 0.0,
    );
  }

  /// Erstellt initiale Ressourcen für ein neues Spiel
  factory Resources.initial() {
    return Resources(
      food: 50,
      buildingMaterials: 30,
      water: 40,
      population: {
        'eggs': 3,
        'larvae': 2,
        'pupae': 0,
        'workers': 5,
        'soldiers': 0,
        'queens': 1,
      },
      queenHealth: 100.0,
      colonyHunger: 0.0,
    );
  }
}
