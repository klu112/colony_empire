import 'dart:math';
import 'package:flutter/material.dart';

/// Repräsentiert den Bauzustand einer Kammer
enum ChamberState {
  /// Kammer ist geplant, aber der Bau wurde noch nicht begonnen
  PLANNED,

  /// Kammer befindet sich im Bauprozess
  BUILDING,

  /// Kammer ist fertiggestellt und voll funktionsfähig
  COMPLETED,
}

/// Repräsentiert eine Kammer im Ameisennest
class Chamber {
  /// Eindeutige ID der Kammer
  final int id;

  /// Typ der Kammer (z.B. 'queen', 'nursery', 'storage')
  final String type;

  /// Größe der Kammer (1-10)
  final int size;

  /// Position der Kammer im Nest
  final Point<double> position;

  /// Aktueller Bauzustand der Kammer
  final ChamberState state;

  /// Baufortschritt in Prozent (0-100)
  final double constructionProgress;

  /// Zeitpunkt des Baubeginns (null wenn noch nicht begonnen)
  final DateTime? constructionStartTime;

  /// Geschätzte Gesamtbauzeit in Sekunden
  final int estimatedConstructionTime;

  /// Anzahl der zugewiesenen Bauarbeiter
  final int assignedWorkers;

  /// Erstellt eine neue Kammer mit den angegebenen Eigenschaften
  Chamber({
    required this.id,
    required this.type,
    required this.size,
    required this.position,
    this.state = ChamberState.PLANNED,
    this.constructionProgress = 0.0,
    this.constructionStartTime,
    this.estimatedConstructionTime = 0,
    this.assignedWorkers = 0,
  });

  /// Erstellt eine Kopie dieser Kammer mit optionalen Änderungen
  Chamber copyWith({
    int? id,
    String? type,
    int? size,
    Point<double>? position,
    ChamberState? state,
    double? constructionProgress,
    DateTime? constructionStartTime,
    int? estimatedConstructionTime,
    int? assignedWorkers,
  }) {
    return Chamber(
      id: id ?? this.id,
      type: type ?? this.type,
      size: size ?? this.size,
      position: position ?? this.position,
      state: state ?? this.state,
      constructionProgress: constructionProgress ?? this.constructionProgress,
      constructionStartTime:
          constructionStartTime ?? this.constructionStartTime,
      estimatedConstructionTime:
          estimatedConstructionTime ?? this.estimatedConstructionTime,
      assignedWorkers: assignedWorkers ?? this.assignedWorkers,
    );
  }

  /// Berechnet die geschätzte Bauzeit basierend auf Kammergröße und Arbeiteranzahl
  static int calculateEstimatedConstructionTime(int size, int assignedWorkers) {
    // Basiszeit abhängig von der Größe (größere Kammern brauchen exponentiell länger)
    final baseTime = size * size * 30; // in Sekunden

    // Mehr Arbeiter beschleunigen den Bau, aber mit abnehmenden Erträgen
    final workerFactor = assignedWorkers > 0 ? sqrt(assignedWorkers) : 0.5;

    // Mindestens 10 Sekunden Bauzeit, selbst mit vielen Arbeitern
    return max(10, (baseTime / workerFactor).round());
  }

  /// Aktualisiert den Baufortschritt basierend auf der vergangenen Zeit
  Chamber updateConstructionProgress(DateTime currentTime) {
    // Wenn Kammer bereits fertig oder noch nicht begonnen wurde
    if (state == ChamberState.COMPLETED || constructionStartTime == null) {
      return this;
    }

    // Vergangene Zeit seit Baubeginn in Sekunden
    final elapsedSeconds =
        currentTime.difference(constructionStartTime!).inSeconds;

    // Berechne neuen Fortschritt
    final newProgress = (elapsedSeconds / estimatedConstructionTime) * 100;

    // Begrenze den Fortschritt auf 0-100%
    final clampedProgress = newProgress.clamp(0.0, 100.0);

    // Bestimme neuen Status
    final newState =
        clampedProgress >= 100 ? ChamberState.COMPLETED : ChamberState.BUILDING;

    return copyWith(constructionProgress: clampedProgress, state: newState);
  }

  /// Beginnt den Bau einer geplanten Kammer
  Chamber startConstruction(DateTime startTime, int workers) {
    if (state != ChamberState.PLANNED) {
      return this;
    }

    final estimatedTime = calculateEstimatedConstructionTime(size, workers);

    return copyWith(
      state: ChamberState.BUILDING,
      constructionStartTime: startTime,
      estimatedConstructionTime: estimatedTime,
      assignedWorkers: workers,
    );
  }

  /// Ändert die Anzahl der zugewiesenen Arbeiter und aktualisiert die Bauzeit
  Chamber adjustWorkers(int newWorkerCount, DateTime currentTime) {
    if (state != ChamberState.BUILDING) {
      return this;
    }

    // Aktuelle Fortschrittsprozent speichern
    final progressPercent = constructionProgress / 100.0;

    // Neue Gesamtbauzeit berechnen
    final newEstimatedTime = calculateEstimatedConstructionTime(
      size,
      newWorkerCount,
    );

    // Bisherige verstrichene Zeit berechnen
    final elapsedTime = (estimatedConstructionTime * progressPercent).round();

    // Neue verbleibende Zeit berechnen
    final remainingTime = newEstimatedTime - elapsedTime;

    // Neuen virtuellen Startpunkt berechnen, damit der Fortschritt konsistent bleibt
    final adjustedStartTime = currentTime.subtract(
      Duration(seconds: elapsedTime),
    );

    return copyWith(
      assignedWorkers: newWorkerCount,
      estimatedConstructionTime: newEstimatedTime,
      constructionStartTime: adjustedStartTime,
    );
  }

  /// Liefert die verbleibende Bauzeit in Sekunden
  int getRemainingConstructionTime(DateTime currentTime) {
    if (state != ChamberState.BUILDING || constructionStartTime == null) {
      return 0;
    }

    final elapsedSeconds =
        currentTime.difference(constructionStartTime!).inSeconds;
    return max(0, estimatedConstructionTime - elapsedSeconds);
  }

  /// Berechnet den Radius der Kammer basierend auf der Größe
  double get radius => 15.0 + (size * 5);

  /// Gibt an, ob die Kammer funktional ist (fertiggestellt)
  bool get isFunctional => state == ChamberState.COMPLETED;

  /// Erstellt eine Farbdarstellung basierend auf dem Baustatus
  Color getStatusColor() {
    switch (state) {
      case ChamberState.PLANNED:
        return Colors.grey.withOpacity(0.6);
      case ChamberState.BUILDING:
        return Colors.amber.withOpacity(0.8);
      case ChamberState.COMPLETED:
        return Colors.green.withOpacity(0.8);
    }
  }

  /// Erstellt eine visuelle Darstellung des Bauprozesses
  Widget buildConstructionVisual(BuildContext context) {
    return Stack(
      children: [
        // Basis-Kammer
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getStatusColor(),
            border: Border.all(
              color: Colors.brown.shade700,
              width: state == ChamberState.PLANNED ? 1 : 2,
            ),
          ),
        ),

        // Fortschrittsanzeige für Kammern im Bau
        if (state == ChamberState.BUILDING)
          Positioned.fill(
            child: CircularProgressIndicator(
              value: constructionProgress / 100,
              strokeWidth: 4,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),

        // Symbol für geplante Kammern
        if (state == ChamberState.PLANNED)
          Positioned.fill(
            child: Icon(
              Icons.add_circle_outline,
              size: radius,
              color: Colors.grey.shade700,
            ),
          ),

        // Arbeiter-Indikator
        if (assignedWorkers > 0)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 10, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    assignedWorkers.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Konvertiert die Kammer in eine Map für Serialisierung
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'size': size,
      'position': {'x': position.x, 'y': position.y},
      'state': state.toString(),
      'constructionProgress': constructionProgress,
      'constructionStartTime': constructionStartTime?.toIso8601String(),
      'estimatedConstructionTime': estimatedConstructionTime,
      'assignedWorkers': assignedWorkers,
    };
  }

  /// Erstellt eine Kammer aus einer Map (für Deserialisierung)
  factory Chamber.fromJson(Map<String, dynamic> json) {
    return Chamber(
      id: json['id'],
      type: json['type'],
      size: json['size'],
      position: Point(json['position']['x'], json['position']['y']),
      state: ChamberState.values.firstWhere(
        (e) => e.toString() == json['state'],
        orElse: () => ChamberState.PLANNED,
      ),
      constructionProgress: json['constructionProgress'],
      constructionStartTime:
          json['constructionStartTime'] != null
              ? DateTime.parse(json['constructionStartTime'])
              : null,
      estimatedConstructionTime: json['estimatedConstructionTime'] ?? 0,
      assignedWorkers: json['assignedWorkers'] ?? 0,
    );
  }
}
