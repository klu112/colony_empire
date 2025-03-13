import 'dart:math';
import 'dart:ui';

/// Repräsentiert eine Kammer im Ameisennest
class Chamber {
  final int id;
  final String type; // queen, nursery, storage, waste, defense
  final int size;
  final Point position;

  const Chamber({
    required this.id,
    required this.type,
    required this.size,
    required this.position,
  });

  Chamber copyWith({int? id, String? type, int? size, Point? position}) {
    return Chamber(
      id: id ?? this.id,
      type: type ?? this.type,
      size: size ?? this.size,
      position: position ?? this.position,
    );
  }

  factory Chamber.fromJson(Map<String, dynamic> json) {
    return Chamber(
      id: json['id'] as int,
      type: json['type'] as String,
      size: json['size'] as int,
      position: Point(
        json['position']['x'] as double,
        json['position']['y'] as double,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'size': size,
      'position': {'x': position.x, 'y': position.y},
    };
  }
}
