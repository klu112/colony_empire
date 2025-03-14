import 'package:flutter/material.dart';
import '../../models/chamber/chamber_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import 'dart:math' as math;

/// Ein Widget, das den Baufortschritt einer Kammer visuell darstellt.
class BuildProgressIndicatorWidget extends StatefulWidget {
  /// Die Kammer, deren Baufortschritt angezeigt werden soll.
  final Chamber chamber;

  /// Gibt an, ob Arbeiter-Icons angezeigt werden sollen.
  final bool showWorkers;

  /// Größenskalierung des Indikators (1.0 = normale Größe).
  final double scale;

  /// Erstellt einen neuen Baufortschrittsindikator.
  const BuildProgressIndicatorWidget({
    Key? key,
    required this.chamber,
    this.showWorkers = true,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  State<BuildProgressIndicatorWidget> createState() =>
      _BuildProgressIndicatorWidgetState();
}

class _BuildProgressIndicatorWidgetState
    extends State<BuildProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  /// Animation controller für Arbeiter-Animationen
  late AnimationController _animationController;

  /// Random-Instanz für visuelle Variation
  final _random = math.Random();

  /// Position offsets für Arbeiter
  late List<Offset> _workerPositions;

  @override
  void initState() {
    super.initState();

    // Animation Controller für kontinuierliche Animationen
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Initialisiere Arbeiter-Positionen
    _initializeWorkerPositions();
  }

  /// Berechnet zufällige Positionen für die Arbeiter-Icons
  void _initializeWorkerPositions() {
    _workerPositions = List.generate(
      widget.chamber.assignedWorkers.clamp(0, 5),
      (_) => Offset(
        (_random.nextDouble() * 0.8 - 0.4) * widget.chamber.radius,
        (_random.nextDouble() * 0.8 - 0.4) * widget.chamber.radius,
      ),
    );
  }

  @override
  void didUpdateWidget(BuildProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Bei Änderung der Arbeiteranzahl Positionen neu berechnen
    if (oldWidget.chamber.assignedWorkers != widget.chamber.assignedWorkers) {
      _initializeWorkerPositions();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wenn die Kammer nicht im Bau ist, zeigen wir nichts an
    if (widget.chamber.state != ChamberState.BUILDING) {
      return const SizedBox.shrink();
    }

    final double size = widget.chamber.radius * 2 * widget.scale;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Kreisförmiger Fortschrittsbalken
              _buildCircularProgress(size),

              // Bauzeit Anzeige
              _buildTimeRemaining(size),

              // Arbeiter-Icons
              if (widget.showWorkers) ..._buildWorkerIcons(size),
            ],
          );
        },
      ),
    );
  }

  /// Erstellt den kreisförmigen Fortschrittsbalken
  Widget _buildCircularProgress(double size) {
    return Center(
      child: SizedBox(
        width: size * 1.1,
        height: size * 1.1,
        child: CircularProgressIndicator(
          value: widget.chamber.constructionProgress / 100,
          strokeWidth: 4 * widget.scale,
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(widget.chamber.constructionProgress),
          ),
        ),
      ),
    );
  }

  /// Erstellt die Anzeige der verbleibenden Bauzeit
  Widget _buildTimeRemaining(double size) {
    // Verbleibende Zeit in Sekunden
    final remainingTime = widget.chamber.getRemainingConstructionTime(
      DateTime.now(),
    );

    // Formatierung: m:ss
    final minutes = (remainingTime / 60).floor();
    final seconds = remainingTime % 60;
    final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(4 * widget.scale),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8 * widget.scale),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, color: Colors.white, size: 12 * widget.scale),
            SizedBox(width: 2 * widget.scale),
            Text(
              timeString,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10 * widget.scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Erstellt animierte Arbeiter-Icons
  List<Widget> _buildWorkerIcons(double size) {
    final workers = <Widget>[];

    // Begrenzen auf maximal 5 angezeigte Arbeiter
    final displayedWorkers = math.min(widget.chamber.assignedWorkers, 5);

    for (int i = 0; i < displayedWorkers; i++) {
      // Für jeden Arbeiter eine eigene Animation berechnen
      final offset = _workerPositions[i];
      final animPhase = _animationController.value + (i * 0.2);
      final bobOffset = math.sin(animPhase * 2 * math.pi) * 2.0;

      workers.add(
        Positioned(
          left: size / 2 + offset.dx,
          top: size / 2 + offset.dy + bobOffset,
          child: _buildWorkerIcon(i),
        ),
      );
    }

    // Wenn es mehr Arbeiter gibt als angezeigt werden, füge eine Zähleranzeige hinzu
    if (widget.chamber.assignedWorkers > 5) {
      workers.add(
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: EdgeInsets.all(4 * widget.scale),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8 * widget.scale),
            ),
            child: Text(
              '+${widget.chamber.assignedWorkers - 5}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10 * widget.scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return workers;
  }

  /// Erstellt ein einzelnes Arbeiter-Icon mit Werkzeugen
  Widget _buildWorkerIcon(int index) {
    // Verschiedene Werkzeugicons für visuelle Abwechslung
    final tools = [
      Icons.build,
      Icons.architecture,
      Icons.handyman,
      Icons.gavel,
      Icons.home_repair_service,
    ];

    // Animation für Arbeitsbewegung
    final toolAngle =
        math.sin((_animationController.value + index * 0.3) * 2 * math.pi) *
        0.3;

    return Stack(
      children: [
        // Ameisenkörper
        Icon(Icons.person, size: 14 * widget.scale, color: Colors.black87),

        // Werkzeug
        Positioned(
          right: -2,
          top: -2,
          child: Transform.rotate(
            angle: toolAngle,
            child: Icon(
              tools[index % tools.length],
              size: 8 * widget.scale,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  /// Bestimmt die Farbe des Fortschrittsbalkens basierend auf dem Fortschritt
  Color _getProgressColor(double progress) {
    if (progress < 25) {
      return Colors.red;
    } else if (progress < 50) {
      return Colors.orange;
    } else if (progress < 75) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}

/// Erweiterung für die Kammer-Klasse zur einfacheren Integration des Indikators
extension BuildProgressIndicatorExtension on Chamber {
  /// Erstellt einen BuildProgressIndicator für diese Kammer
  Widget buildProgressIndicator({bool showWorkers = true, double scale = 1.0}) {
    return BuildProgressIndicatorWidget(
      chamber: this,
      showWorkers: showWorkers,
      scale: scale,
    );
  }
}
