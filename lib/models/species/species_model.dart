/// Repräsentiert eine Ameisenart mit einzigartigen Eigenschaften
class Species {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String strengths;
  final String weaknesses;
  final Map<String, double> bonuses;
  final String color;

  const Species({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.strengths,
    required this.weaknesses,
    required this.bonuses,
    required this.color,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      description: json['description'] as String,
      strengths: json['strengths'] as String,
      weaknesses: json['weaknesses'] as String,
      bonuses: Map<String, double>.from(json['bonuses'] as Map),
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'description': description,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'bonuses': bonuses,
      'color': color,
    };
  }
}
