import 'dart:ui';

/// Repräsentiert eine einzelne Ameise im Spiel
class Ant {
  final int id;
  final String type; // queen, worker, soldier, scout
  final Point position;
  final Point target;
  final String? task; // foraging, building, caregiving, defense, exploration
  final int chamberID;

  const Ant({
    required this.id,
    required this.type,
    required this.position,
    required this.target,
    this.task,
    required this.chamberID,
  });

  Ant copyWith({
    int? id,
    String? type,
    Point? position,
    Point? target,
    String? task,
    int? chamberID,
  }) {
    return Ant(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      target: target ?? this.target,
      task: task ?? this.task,
      chamberID: chamberID ?? this.chamberID,
    );
  }

  factory Ant.fromJson(Map<String, dynamic> json) {
    return Ant(
      id: json['id'] as int,
      type: json['type'] as String,
      position: Point(
        json['position']['x'] as double,
        json['position']['y'] as double,
      ),
      target: Point(
        json['target']['x'] as double,
        json['target']['y'] as double,
      ),
      task: json['task'] as String?,
      chamberID: json['chamberID'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'position': {'x': position.x, 'y': position.y},
      'target': {'x': target.x, 'y': target.y},
      'task': task,
      'chamberID': chamberID,
    };
  }
}
