import 'dart:math';
import 'package:flutter/material.dart';

/// Verschiedene Arten von Pheromonen, die Ameisen zur Kommunikation nutzen
enum PheromoneType {
  /// Markiert den Weg zu einer Nahrungsquelle
  food,

  /// Markiert den Weg zurück zum Nest
  nest,

  /// Warnt vor Gefahr
  danger,
}

/// System zur Simulation von Pheromonspuren
/// Verwaltet ein 2D-Grid mit verschiedenen Pheromontypen und deren Verfall
class PheromoneSystem {
  /// Die Breite des Simulationsbereichs
  final int width;

  /// Die Höhe des Simulationsbereichs
  final int height;

  /// Die Auflösung des Grids (höher = detaillierter, aber rechenintensiver)
  final int resolution;

  /// Das Grid für alle Pheromontypen
  /// [x][y][pheromonType] = Intensität (0.0 - 1.0)
  late List<List<Map<PheromoneType, double>>> _grid;

  /// Maximale Intensität für jede Pheromonspur
  static const double _maxIntensity = 1.0;

  /// Verfallsraten für jeden Pheromontyp (pro Aktualisierung)
  final Map<PheromoneType, double> _decayRates = {
    PheromoneType.food: 0.005, // Nahrungspheromone halten lange
    PheromoneType.nest: 0.003, // Nestpheromone halten am längsten
    PheromoneType.danger: 0.01, // Gefahrenpheromone verfallen schnell
  };

  /// Diffusionsradius für Pheromone in Zellen
  final int _diffusionRadius = 1;

  /// Farbkodierung für jeden Pheromontyp
  static const Map<PheromoneType, Color> pheromonColors = {
    PheromoneType.food: Colors.blue,
    PheromoneType.nest: Colors.green,
    PheromoneType.danger: Colors.red,
  };

  /// Erstellt ein neues PheromoneSystem mit den gegebenen Dimensionen
  ///
  /// [width] und [height] geben die Größe des simulierten Bereichs an
  /// [resolution] bestimmt die Größe der Grid-Zellen (kleiner = höhere Auflösung)
  PheromoneSystem({
    required this.width,
    required this.height,
    this.resolution = 5,
  }) {
    // Berechne Grid-Dimensionen basierend auf Auflösung
    final gridWidth = (width / resolution).ceil();
    final gridHeight = (height / resolution).ceil();

    // Initialisiere das Grid mit leeren Einträgen
    _grid = List.generate(
      gridWidth,
      (_) => List.generate(gridHeight, (_) => <PheromoneType, double>{}),
    );
  }

  /// Fügt eine Pheromonspur an einer bestimmten Position hinzu oder verstärkt sie
  ///
  /// [position] ist die Position in Weltkoordinaten (nicht Grid-Koordinaten)
  /// [type] ist der Pheromontyp
  /// [intensity] ist die Intensität (0.0 - 1.0, Standard: 0.5)
  void addPheromone(
    Offset position,
    PheromoneType type, {
    double intensity = 0.5,
  }) {
    // Konvertiere Weltkoordinaten in Grid-Koordinaten
    final gridX = (position.dx / resolution).floor();
    final gridY = (position.dy / resolution).floor();

    // Prüfe, ob die Koordinaten im Grid liegen
    if (gridX < 0 ||
        gridX >= _grid.length ||
        gridY < 0 ||
        gridY >= _grid[0].length) {
      return;
    }

    // Pheromonspur hinzufügen oder verstärken
    final currentIntensity = _grid[gridX][gridY][type] ?? 0.0;
    final newIntensity = min(currentIntensity + intensity, _maxIntensity);
    _grid[gridX][gridY][type] = newIntensity;

    // Diffusion zu benachbarten Zellen mit verringerter Intensität
    _diffusePheromone(gridX, gridY, type, newIntensity);
  }

  /// Verbreitet Pheromone auf benachbarte Zellen mit geringerer Intensität
  void _diffusePheromone(
    int x,
    int y,
    PheromoneType type,
    double sourceIntensity,
  ) {
    for (int dx = -_diffusionRadius; dx <= _diffusionRadius; dx++) {
      for (int dy = -_diffusionRadius; dy <= _diffusionRadius; dy++) {
        // Überspringe die Quellzelle
        if (dx == 0 && dy == 0) continue;

        final nx = x + dx;
        final ny = y + dy;

        // Prüfe, ob die Zelle im Grid liegt
        if (nx < 0 || nx >= _grid.length || ny < 0 || ny >= _grid[0].length) {
          continue;
        }

        // Berechne Entfernung zur Quellzelle
        final distance = sqrt(dx * dx + dy * dy);
        if (distance > _diffusionRadius) continue;

        // Berechne Intensität basierend auf Entfernung (linear abnehmend)
        final diffusionFactor = 1.0 - (distance / (_diffusionRadius + 1));
        final diffusionIntensity = sourceIntensity * diffusionFactor * 0.3;

        // Intensität in der Zielzelle aktualisieren (nur erhöhen, nicht verringern)
        final currentIntensity = _grid[nx][ny][type] ?? 0.0;
        if (diffusionIntensity > currentIntensity) {
          _grid[nx][ny][type] = diffusionIntensity;
        }
      }
    }
  }

  /// Aktualisiert alle Pheromone und lässt sie verfallen
  void update() {
    for (int x = 0; x < _grid.length; x++) {
      for (int y = 0; y < _grid[x].length; y++) {
        final cellPheromones = _grid[x][y];

        // Jeden Pheromontyp in der Zelle aktualisieren
        cellPheromones.forEach((type, intensity) {
          // Intensität verringern
          final decayRate = _decayRates[type] ?? 0.01;
          final newIntensity = max(0.0, intensity - decayRate);

          // Aktualisieren oder entfernen, wenn zu schwach
          if (newIntensity > 0.01) {
            cellPheromones[type] = newIntensity;
          } else {
            cellPheromones.remove(type);
          }
        });
      }
    }
  }

  /// Liefert die Intensität eines bestimmten Pheromontyps an einer Position
  ///
  /// [position] ist die Position in Weltkoordinaten
  /// [type] ist der abzufragende Pheromontyp
  /// Gibt einen Wert zwischen 0.0 und 1.0 zurück
  double getIntensityAt(Offset position, PheromoneType type) {
    final gridX = (position.dx / resolution).floor();
    final gridY = (position.dy / resolution).floor();

    // Prüfe, ob die Koordinaten im Grid liegen
    if (gridX < 0 ||
        gridX >= _grid.length ||
        gridY < 0 ||
        gridY >= _grid[0].length) {
      return 0.0;
    }

    return _grid[gridX][gridY][type] ?? 0.0;
  }

  /// Findet die Richtung mit der höchsten Pheromonintensität eines bestimmten Typs
  /// von einer gegebenen Position aus
  ///
  /// [position] ist die aktuelle Position
  /// [type] ist der gesuchte Pheromontyp
  /// [searchRadius] ist der Suchradius in Grid-Einheiten
  ///
  /// Gibt die Richtung mit der höchsten Intensität zurück oder null, wenn keine
  /// Pheromone gefunden wurden
  Offset? findStrongestDirection(
    Offset position,
    PheromoneType type, {
    int searchRadius = 3,
  }) {
    final gridX = (position.dx / resolution).floor();
    final gridY = (position.dy / resolution).floor();

    double maxIntensity = 0.0;
    Offset? bestDirection;

    // Suche im Umkreis nach der stärksten Spur
    for (int dx = -searchRadius; dx <= searchRadius; dx++) {
      for (int dy = -searchRadius; dy <= searchRadius; dy++) {
        // Überspringe die aktuelle Position
        if (dx == 0 && dy == 0) continue;

        final nx = gridX + dx;
        final ny = gridY + dy;

        // Prüfe, ob die Zelle im Grid liegt
        if (nx < 0 || nx >= _grid.length || ny < 0 || ny >= _grid[0].length) {
          continue;
        }

        final intensity = _grid[nx][ny][type] ?? 0.0;

        if (intensity > maxIntensity) {
          maxIntensity = intensity;
          // Richtungsvektor von der aktuellen Position zur Zelle mit höchster Intensität
          bestDirection = Offset(dx.toDouble(), dy.toDouble());
        }
      }
    }

    // Normalisiere den Richtungsvektor, wenn einer gefunden wurde
    if (bestDirection != null && bestDirection != Offset.zero) {
      final magnitude = bestDirection.distance;
      bestDirection = bestDirection / magnitude;
    }

    return maxIntensity > 0.05 ? bestDirection : null;
  }

  /// Erstellt ein CustomPaint für die Visualisierung der Pheromonspuren
  ///
  /// [showTypes] gibt an, welche Pheromontypen angezeigt werden sollen
  /// [opacity] steuert die Transparenz der Visualisierung
  Widget buildVisualization({
    List<PheromoneType> showTypes = const [
      PheromoneType.food,
      PheromoneType.nest,
      PheromoneType.danger,
    ],
    double opacity = 0.6,
  }) {
    return CustomPaint(
      painter: _PheromonePainter(
        grid: _grid,
        showTypes: showTypes,
        opacity: opacity,
        resolution: resolution.toDouble(),
      ),
      child: Container(width: width.toDouble(), height: height.toDouble()),
    );
  }

  /// Löscht alle Pheromone eines bestimmten Typs
  void clearPheromoneType(PheromoneType type) {
    for (int x = 0; x < _grid.length; x++) {
      for (int y = 0; y < _grid[x].length; y++) {
        _grid[x][y].remove(type);
      }
    }
  }

  /// Löscht alle Pheromone im System
  void clearAllPheromones() {
    for (int x = 0; x < _grid.length; x++) {
      for (int y = 0; y < _grid[x].length; y++) {
        _grid[x][y].clear();
      }
    }
  }
}

/// CustomPainter für die Visualisierung der Pheromonspuren
class _PheromonePainter extends CustomPainter {
  final List<List<Map<PheromoneType, double>>> grid;
  final List<PheromoneType> showTypes;
  final double opacity;
  final double resolution;

  _PheromonePainter({
    required this.grid,
    required this.showTypes,
    required this.opacity,
    required this.resolution,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int x = 0; x < grid.length; x++) {
      for (int y = 0; y < grid[x].length; y++) {
        final cellPheromones = grid[x][y];

        // Position der Zelle in Weltkoordinaten
        final cellRect = Rect.fromLTWH(
          x * resolution,
          y * resolution,
          resolution,
          resolution,
        );

        // Für jeden sichtbaren Pheromontyp zeichnen
        for (final type in showTypes) {
          final intensity = cellPheromones[type] ?? 0.0;

          if (intensity > 0.01) {
            // Farbe mit angepasster Transparenz basierend auf Intensität
            final color = PheromoneSystem.pheromonColors[type]!.withOpacity(
              intensity * opacity,
            );

            // Zeichne einen Kreis für das Pheromon
            canvas.drawCircle(
              cellRect.center,
              resolution * 0.6 * intensity,
              Paint()..color = color,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PheromonePainter oldDelegate) {
    return true; // Optimierung: Nur neu zeichnen, wenn sich das Grid geändert hat
  }
}
