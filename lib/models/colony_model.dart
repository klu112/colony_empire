import 'dart:math';
import 'dart:ui';
import 'package:colony_empire/models/ant/ant_model.dart';
import 'package:colony_empire/models/chamber/chamber_model.dart';
import 'package:colony_empire/models/chamber/tunnel_model.dart';
import 'package:colony_empire/models/resources/resources_model.dart';
import 'package:colony_empire/models/resources/task_allocation_model.dart';
import 'package:colony_empire/models/species/species_model.dart';

/// Hauptklasse, die den gesamten Spielzustand repräsentiert
class Colony {
  final String? selectedSpeciesId;
  final Resources resources;
  final TaskAllocation taskAllocation;
  final List<Chamber> chambers;
  final List<Tunnel> tunnels;
  final List<Ant> ants;
  final int time;
  final int speed; // 0: paused, 1: normal, 2: fast

  const Colony({
    this.selectedSpeciesId,
    required this.resources,
    required this.taskAllocation,
    required this.chambers,
    required this.tunnels,
    required this.ants,
    required this.time,
    required this.speed,
  });

  Colony copyWith({
    String? selectedSpeciesId,
    Resources? resources,
    TaskAllocation? taskAllocation,
    List<Chamber>? chambers,
    List<Tunnel>? tunnels,
    List<Ant>? ants,
    int? time,
    int? speed,
  }) {
    return Colony(
      selectedSpeciesId: selectedSpeciesId ?? this.selectedSpeciesId,
      resources: resources ?? this.resources,
      taskAllocation: taskAllocation ?? this.taskAllocation,
      chambers: chambers ?? List.from(this.chambers),
      tunnels: tunnels ?? List.from(this.tunnels),
      ants: ants ?? List.from(this.ants),
      time: time ?? this.time,
      speed: speed ?? this.speed,
    );
  }

  factory Colony.initial() {
    // Initialer Zustand mit Königinnenkammer und Basisressourcen
    return Colony(
      selectedSpeciesId: null,
      resources: Resources.initial(),
      taskAllocation: TaskAllocation.initial(),
      chambers: [
        Chamber(id: 1, type: 'queen', size: 1, position: const Point(150, 150)),
        Chamber(
          id: 2,
          type: 'nursery',
          size: 1,
          position: const Point(220, 120),
        ),
        Chamber(
          id: 3,
          type: 'storage',
          size: 1,
          position: const Point(100, 200),
        ),
      ],
      tunnels: [const Tunnel(from: 1, to: 2), const Tunnel(from: 1, to: 3)],
      ants: [],
      time: 0,
      speed: 1,
    );
  }

  factory Colony.fromJson(Map<String, dynamic> json) {
    return Colony(
      selectedSpeciesId: json['selectedSpeciesId'] as String?,
      resources: Resources.fromJson(json['resources'] as Map<String, dynamic>),
      taskAllocation: TaskAllocation.fromJson(
        json['taskAllocation'] as Map<String, dynamic>,
      ),
      chambers:
          (json['chambers'] as List)
              .map((e) => Chamber.fromJson(e as Map<String, dynamic>))
              .toList(),
      tunnels:
          (json['tunnels'] as List)
              .map((e) => Tunnel.fromJson(e as Map<String, dynamic>))
              .toList(),
      ants:
          (json['ants'] as List)
              .map((e) => Ant.fromJson(e as Map<String, dynamic>))
              .toList(),
      time: json['time'] as int,
      speed: json['speed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedSpeciesId': selectedSpeciesId,
      'resources': resources.toJson(),
      'taskAllocation': taskAllocation.toJson(),
      'chambers': chambers.map((e) => e.toJson()).toList(),
      'tunnels': tunnels.map((e) => e.toJson()).toList(),
      'ants': ants.map((e) => e.toJson()).toList(),
      'time': time,
      'speed': speed,
    };
  }
}
