import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ant/ant_model.dart';
import '../../providers/game_provider.dart';
import '../../services/view/view_manager.dart';
import '../../utils/constants/colors.dart';

class SurfaceViewWidget extends StatefulWidget {
  const SurfaceViewWidget({super.key});

  @override
  State<SurfaceViewWidget> createState() => _SurfaceViewWidgetState();
}

class _SurfaceViewWidgetState extends State<SurfaceViewWidget>
    with SingleTickerProviderStateMixin {
  // Zufallsgenerator für Positionierung
  final Random _random = Random();

  // Liste der Nahrungsquellen
  final List<_FoodSource> _foodSources = [];

  // Liste der Ameisen an der Oberfläche
  final List<_SurfaceAnt> _surfaceAnts = [];

  // Animation controller für verschiedene Effekte
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Animation Controller initialisieren
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Nahrungsquellen generieren
    _generateFoodSources();

    // Ameisen initialisieren
    _initializeAnts();

    // Timer für Bewegungen der Ameisen
    Future.delayed(const Duration(milliseconds: 100), () {
      _startAntMovement();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Generiert zufällige Nahrungsquellen auf der Oberfläche
  void _generateFoodSources() {
    // Anzahl der Nahrungsquellen basierend auf Größe
    final size = MediaQuery.of(context).size;
    final count = max(5, (size.width * size.height) ~/ 40000);

    for (int i = 0; i < count; i++) {
      // Verschiedene Typen von Nahrung (Samen, Blätter, tote Insekten)
      final type = _random.nextInt(3);
      final size = _random.nextDouble() * 15 + 10; // 10-25

      _foodSources.add(
        _FoodSource(
          position: Offset(
            _random.nextDouble() * MediaQuery.of(context).size.width,
            _random.nextDouble() * MediaQuery.of(context).size.height,
          ),
          type: type,
          size: size,
          value: size * 2, // Größere Nahrung = mehr Wert
        ),
      );
    }
  }

  // Initialisiert Ameisen auf der Oberfläche
  void _initializeAnts() {
    // Starte mit einigen Ameisen
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Anzahl basierend auf Aufgabenzuweisung für Nahrungssuche
    final foragingAllocation = gameProvider.taskAllocation.foraging;
    final numberOfAnts = max(2, (foragingAllocation / 10).round());

    for (int i = 0; i < numberOfAnts; i++) {
      _addSurfaceAnt();
    }
  }

  // Fügt eine neue Ameise zur Oberfläche hinzu
  void _addSurfaceAnt() {
    // Position des Nesteingangs (Mitte unten)
    final size = MediaQuery.of(context).size;
    final nestPosition = Offset(size.width / 2, size.height * 0.8);

    _surfaceAnts.add(
      _SurfaceAnt(
        position: nestPosition,
        angle: _random.nextDouble() * 2 * pi,
        speed: _random.nextDouble() * 1.0 + 0.5, // 0.5-1.5 Geschwindigkeit
        carryingFood: false,
      ),
    );
  }

  // Startet die Bewegung der Ameisen
  void _startAntMovement() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      setState(() {
        // Jede Ameise bewegen
        for (int i = 0; i < _surfaceAnts.length; i++) {
          _moveAnt(i);
        }
      });

      // Rekursiver Aufruf für Animation
      _startAntMovement();
    });
  }

  // Bewegt eine einzelne Ameise
  void _moveAnt(int index) {
    if (index >= _surfaceAnts.length) return;

    final ant = _surfaceAnts[index];
    final size = MediaQuery.of(context).size;
    final nestPosition = Offset(size.width / 2, size.height * 0.8);

    // Wenn die Ameise Nahrung trägt, zum Nest zurückkehren
    if (ant.carryingFood) {
      // Bewegung Richtung Nest
      final dx = nestPosition.dx - ant.position.dx;
      final dy = nestPosition.dy - ant.position.dy;
      final distance = sqrt(dx * dx + dy * dy);

      // Wenn nahe am Nest, Nahrung abliefern
      if (distance < 10) {
        ant.carryingFood = false;
        ant.angle = _random.nextDouble() * 2 * pi; // Neue Richtung

        // Ressourcen erhöhen (in einem echten Spiel würdest du das im Provider machen)
        // gameProvider.addResource('food', ant.foodValue);
      } else {
        // Zum Nest bewegen
        final speed = ant.speed * 0.7; // Langsamer mit Nahrung
        ant.position = Offset(
          ant.position.dx + (dx / distance) * speed,
          ant.position.dy + (dy / distance) * speed,
        );
        // Winkel anpassen, um in Richtung Nest zu zeigen
        ant.angle = atan2(dy, dx);
      }
    } else {
      // Nahrung suchen
      // Zufällig bewegen oder zu naher Nahrungsquelle
      bool foundFood = false;

      // Prüfen, ob Nahrung in der Nähe ist
      for (int i = 0; i < _foodSources.length; i++) {
        final food = _foodSources[i];
        final dx = food.position.dx - ant.position.dx;
        final dy = food.position.dy - ant.position.dy;
        final distance = sqrt(dx * dx + dy * dy);

        // Wenn Nahrung nah genug ist, dorthin bewegen
        if (distance < 50) {
          // Bewegung zur Nahrung
          if (distance < 5) {
            // Nahrung aufnehmen
            ant.carryingFood = true;
            ant.foodType = food.type;
            ant.foodValue = food.value;

            // Nahrungsquelle verkleinern oder entfernen
            food.value -= min(5, food.value);
            if (food.value <= 0) {
              _foodSources.removeAt(i);
            } else {
              food.size = max(5, food.size - 2);
            }

            foundFood = true;
            break;
          } else {
            // Zur Nahrung bewegen
            ant.position = Offset(
              ant.position.dx + (dx / distance) * ant.speed,
              ant.position.dy + (dy / distance) * ant.speed,
            );
            // Winkel anpassen
            ant.angle = atan2(dy, dx);
            foundFood = true;
            break;
          }
        }
      }

      // Wenn keine Nahrung in der Nähe, zufällig bewegen
      if (!foundFood) {
        // Leicht zufällige Winkeländerung
        ant.angle += (_random.nextDouble() - 0.5) * 0.5;

        // Bewegung in Richtung des Winkels
        ant.position = Offset(
          ant.position.dx + cos(ant.angle) * ant.speed,
          ant.position.dy + sin(ant.angle) * ant.speed,
        );

        // Bildschirmgrenzen prüfen
        if (ant.position.dx < 0 ||
            ant.position.dx > size.width ||
            ant.position.dy < 0 ||
            ant.position.dy > size.height) {
          // Wenn zu weit weg, wieder zum Nest
          ant.position = nestPosition;
          ant.angle = _random.nextDouble() * 2 * pi;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hintergrund (Gras)
        _buildBackground(),

        // Nahrungsquellen
        ..._foodSources.map((food) => _buildFoodSource(food)),

        // Nesteingang
        _buildNestEntrance(),

        // Ameisen
        ..._surfaceAnts.map((ant) => _buildAnt(ant)),

        // Nesteingang-Interaktionsbutton (ViewManager vom Hauptscreen verwaltet)
        Consumer<ViewManager>(
          builder: (context, viewManager, child) {
            return viewManager.buildSurfaceEntrance(context);
          },
        ),
      ],
    );
  }

  // Baut den grasbewachsenen Hintergrund
  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _GrassBackgroundPainter(
            animation: _animationController.value,
          ),
          child: Container(width: double.infinity, height: double.infinity),
        );
      },
    );
  }

  // Baut den Nesteingang in der Mitte
  Widget _buildNestEntrance() {
    final size = MediaQuery.of(context).size;

    return Positioned(
      bottom: size.height * 0.2,
      left: size.width / 2 - 40,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.brown.shade800,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Baut eine Nahrungsquelle
  Widget _buildFoodSource(_FoodSource food) {
    // Verschiedene Arten von Nahrung
    IconData icon;
    Color color;

    switch (food.type) {
      case 0: // Samen
        icon = Icons.grain;
        color = Colors.brown.shade300;
        break;
      case 1: // Blatt
        icon = Icons.eco;
        color = Colors.green.shade400;
        break;
      case 2: // Totes Insekt
        icon = Icons.pest_control;
        color = Colors.grey.shade700;
        break;
      default:
        icon = Icons.circle;
        color = Colors.orange;
    }

    return Positioned(
      left: food.position.dx - food.size / 2,
      top: food.position.dy - food.size / 2,
      width: food.size,
      height: food.size,
      child: Icon(icon, color: color, size: food.size),
    );
  }

  // Baut eine Ameise
  Widget _buildAnt(_SurfaceAnt ant) {
    return Positioned(
      left: ant.position.dx - 8,
      top: ant.position.dy - 8,
      child: Transform.rotate(
        angle: ant.angle,
        child: Stack(
          children: [
            // Ameisenkörper
            Container(
              width: 16,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Wenn Nahrung trägt, zeige sie an
            if (ant.carryingFood)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        ant.foodType == 0
                            ? Colors.brown.shade300
                            : ant.foodType == 1
                            ? Colors.green.shade400
                            : Colors.grey.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custompainter für den Grashintergrund
class _GrassBackgroundPainter extends CustomPainter {
  final double animation;
  final Random _random = Random(42); // Fester Seed für Konsistenz

  _GrassBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Hintergrund (Erde/Sand)
    final backgroundPaint = Paint()..color = Colors.brown.shade200;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Himmel
    final skyPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade300, Colors.lightBlue.shade100],
            stops: const [0.0, 0.7],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
      skyPaint,
    );

    // Gras am Boden
    final grassPaint = Paint()..color = Colors.green.shade600;
    final groundPath = Path();
    groundPath.moveTo(0, size.height * 0.7);
    groundPath.lineTo(size.width, size.height * 0.7);
    groundPath.lineTo(size.width, size.height);
    groundPath.lineTo(0, size.height);
    groundPath.close();
    canvas.drawPath(groundPath, grassPaint);

    // Grashalme
    final grassBladePaint = Paint()..color = Colors.green.shade400;

    // Anzahl Grashalme basierend auf Bildschirmbreite
    final numGrassBlades = (size.width / 15).round();

    for (int i = 0; i < numGrassBlades; i++) {
      final x = i * (size.width / numGrassBlades);
      final baseHeight = size.height * 0.7;
      final grassHeight = _random.nextDouble() * 20 + 10;

      // Wind-Animation
      final windOffset = sin(animation * 2 * pi + i * 0.2) * 5;

      final bladePath = Path();
      bladePath.moveTo(x, baseHeight);
      bladePath.quadraticBezierTo(
        x + windOffset,
        baseHeight - grassHeight / 2,
        x + windOffset * 1.5,
        baseHeight - grassHeight,
      );

      canvas.drawPath(
        bladePath,
        grassBladePaint
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Wolken
    _drawClouds(canvas, size);
  }

  void _drawClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.8);

    // Bewege Wolken langsam von rechts nach links
    final cloudOffset = (animation * size.width * 0.3) % (size.width * 1.5);

    // Erstelle ein paar Wolken
    for (int i = 0; i < 4; i++) {
      final x = (i * size.width / 2) - cloudOffset;
      final y = size.height * (0.1 + i * 0.1);
      final cloudSize = _random.nextDouble() * 40 + 60;

      // Eine Wolke besteht aus mehreren überlappenden Kreisen
      for (int j = 0; j < 5; j++) {
        final offsetX = j * cloudSize * 0.3;
        final offsetY = (j % 2) * cloudSize * 0.1;
        final radius = cloudSize * (0.4 + (_random.nextDouble() * 0.2));

        canvas.drawCircle(Offset(x + offsetX, y + offsetY), radius, cloudPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GrassBackgroundPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

// Hilfsklasse für Nahrungsquellen
class _FoodSource {
  Offset position;
  int type; // 0=Samen, 1=Blatt, 2=Insekt
  double size;
  double value;

  _FoodSource({
    required this.position,
    required this.type,
    required this.size,
    required this.value,
  });
}

// Hilfsklasse für Ameisen auf der Oberfläche
class _SurfaceAnt {
  Offset position;
  double angle;
  double speed;
  bool carryingFood;
  int foodType = 0;
  double foodValue = 0;

  _SurfaceAnt({
    required this.position,
    required this.angle,
    required this.speed,
    required this.carryingFood,
  });
}
