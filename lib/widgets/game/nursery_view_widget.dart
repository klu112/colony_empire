import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/resources/resources_model.dart';
import '../../services/simulation/ant_lifecycle_manager.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';

/// Widget zur Visualisierung der Brutpflege und Entwicklungsstadien
class NurseryViewWidget extends StatefulWidget {
  /// Gibt an, ob das Widget in einer kompakten Version angezeigt werden soll
  final bool compact;

  /// Erstellt eine neue NurseryView
  const NurseryViewWidget({Key? key, this.compact = false}) : super(key: key);

  @override
  State<NurseryViewWidget> createState() => _NurseryViewWidgetState();
}

class _NurseryViewWidgetState extends State<NurseryViewWidget>
    with TickerProviderStateMixin {
  // Animation Controller für pflegende Ameisen
  late AnimationController _antAnimationController;
  late AnimationController _pulseAnimationController;

  // Random für visuelle Variation
  final Random _random = Random();

  // Speichert die Positionen der Pflegeameisen
  late List<_CaretakerAnt> _caretakerAnts;

  @override
  void initState() {
    super.initState();

    // Animator für die pflegenden Ameisen
    _antAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    // Animation für das Pulsieren der Eier und Larven
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Initialisiere Pflegeameisen
    _caretakerAnts = [];

    // Nach dem ersten Frame die Pflegeameisen positionieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCaretakerAnts();
    });
  }

  @override
  void dispose() {
    _antAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  /// Initialisiert die Pflegeameisen mit zufälligen Positionen und Zielen
  void _initializeCaretakerAnts() {
    if (!mounted) return;

    // Rufe die Größe des Bildschirms ab
    final Size cardSize = context.size ?? Size(300, 200);

    // Anzahl der Pflegeameisen ist abhängig von der Größe des Widgets
    final int antCount = widget.compact ? 3 : 5;

    setState(() {
      _caretakerAnts = List.generate(antCount, (index) {
        return _CaretakerAnt(
          position: Offset(
            _random.nextDouble() * cardSize.width * 0.8 + cardSize.width * 0.1,
            _random.nextDouble() * cardSize.height * 0.8 +
                cardSize.height * 0.1,
          ),
          targetIndex: _random.nextInt(3), // Ziel: 0=Eier, 1=Larven, 2=Puppen
          size: _random.nextDouble() * 4 + 8, // Größe 8-12
          color: Colors.black87,
        );
      });
    });
  }

  /// Bewegt die Pflegeameisen zu ihren Zielen
  void _moveCaretakerAnts(Size size, Map<int, Rect> targetRects) {
    final updatedAnts = <_CaretakerAnt>[];

    for (final ant in _caretakerAnts) {
      // Das aktuelle Zielrechteck abrufen
      final targetRect = targetRects[ant.targetIndex];
      if (targetRect == null) continue;

      // Zufälliges Ziel innerhalb des Zielrechtecks
      final targetX = targetRect.left + _random.nextDouble() * targetRect.width;
      final targetY = targetRect.top + _random.nextDouble() * targetRect.height;
      final target = Offset(targetX, targetY);

      // Bewegungsrichtung und Distanz berechnen
      final direction = target - ant.position;
      final distance = direction.distance;

      // Wenn die Ameise ihr Ziel erreicht hat, neues Ziel setzen
      _CaretakerAnt updatedAnt;
      if (distance < 5.0) {
        // Neues Ziel festlegen
        updatedAnt = ant.copyWith(targetIndex: _random.nextInt(3));
      } else {
        // Bewegung zur aktuellen Position berechnen
        final normalizedDirection = direction / distance;
        final speed =
            1.0 +
            _random.nextDouble() * 0.5; // Geschwindigkeit zwischen 1.0-1.5

        // Position aktualisieren
        updatedAnt = ant.copyWith(
          position: ant.position + normalizedDirection * speed,
        );
      }

      updatedAnts.add(updatedAnt);
    }

    setState(() {
      _caretakerAnts = updatedAnts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final resources = gameProvider.resources;
        final caregiverCount = _getCaregiverCount(gameProvider);

        return AnimatedBuilder(
          animation: Listenable.merge([
            _antAnimationController,
            _pulseAnimationController,
          ]),
          builder: (context, child) {
            final Map<int, Rect> targetRects = {};

            return Card(
              elevation: 2,
              margin: EdgeInsets.all(widget.compact ? 4.0 : 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                side: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Bewege die Pflegeameisen (wenn das Widget nicht kompakt ist)
                  if (!widget.compact && _caretakerAnts.isNotEmpty) {
                    _moveCaretakerAnts(
                      Size(constraints.maxWidth, constraints.maxHeight),
                      targetRects,
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(widget.compact ? 8.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        _buildHeader(caregiverCount),

                        SizedBox(height: widget.compact ? 8.0 : 16.0),

                        // Inhalt
                        Expanded(
                          child: Stack(
                            children: [
                              // Layout für Brutpflegestadien
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Eier
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, stageConstraints) {
                                        // Speichere das Rechteck für Eier in targetRects
                                        targetRects[0] = Rect.fromLTWH(
                                          0,
                                          0,
                                          stageConstraints.maxWidth,
                                          stageConstraints.maxHeight,
                                        );
                                        return _buildStageWidget(
                                          context,
                                          resources,
                                          'eggs',
                                          'Eier',
                                          Icons.egg_outlined,
                                          AppColors.amber,
                                          _pulseAnimationController.value,
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(height: widget.compact ? 6.0 : 12.0),

                                  // Larven
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, stageConstraints) {
                                        // Speichere das Rechteck für Larven in targetRects
                                        targetRects[1] = Rect.fromLTWH(
                                          0,
                                          targetRects[0]!.height +
                                              (widget.compact ? 6.0 : 12.0),
                                          stageConstraints.maxWidth,
                                          stageConstraints.maxHeight,
                                        );
                                        return _buildStageWidget(
                                          context,
                                          resources,
                                          'larvae',
                                          'Larven',
                                          Icons.pets,
                                          AppColors.secondary,
                                          _pulseAnimationController.value,
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(height: widget.compact ? 6.0 : 12.0),

                                  // Puppen
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, stageConstraints) {
                                        // Speichere das Rechteck für Puppen in targetRects
                                        targetRects[2] = Rect.fromLTWH(
                                          0,
                                          targetRects[0]!.height +
                                              targetRects[1]!.height +
                                              (widget.compact ? 12.0 : 24.0),
                                          stageConstraints.maxWidth,
                                          stageConstraints.maxHeight,
                                        );
                                        return _buildStageWidget(
                                          context,
                                          resources,
                                          'pupae',
                                          'Puppen',
                                          Icons.shopping_bag_outlined,
                                          AppColors.primary,
                                          0.0, // Puppen pulsieren nicht
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // Pflegeameisen
                              if (!widget.compact)
                                ..._caretakerAnts.map(
                                  (ant) => _buildCaretakerAnt(ant),
                                ),
                            ],
                          ),
                        ),

                        // Anzeige der verbleibenden Zeit bis zur nächsten Entwicklung
                        if (!widget.compact) ...[
                          SizedBox(height: 8.0),
                          _buildNextDevelopmentInfo(gameProvider),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Baut die Kopfzeile des Widgets
  Widget _buildHeader(int caregiverCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Titel
        Text(
          'Brutkammer',
          style: TextStyle(
            fontSize: widget.compact ? 14.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        // Anzahl der Pflegeameisen
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.healing,
                size: widget.compact ? 12 : 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                '$caregiverCount Pfleger',
                style: TextStyle(
                  fontSize: widget.compact ? 10 : 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Baut ein Widget für ein Entwicklungsstadium
  Widget _buildStageWidget(
    BuildContext context,
    Resources resources,
    String stageKey,
    String stageLabel,
    IconData icon,
    Color color,
    double pulseValue,
  ) {
    // Anzahl der Individuen in diesem Stadium
    final count = resources.population[stageKey] ?? 0;
    final scaleFactor = 1.0 + (pulseValue * 0.1); // Max 10% größer

    return Container(
      padding: EdgeInsets.all(widget.compact ? 8.0 : 12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Symbol und Anzahl
          Row(
            children: [
              Transform.scale(
                scale: scaleFactor,
                child: Icon(icon, color: color, size: widget.compact ? 16 : 24),
              ),
              SizedBox(width: widget.compact ? 4.0 : 8.0),
              Expanded(
                child: Text(
                  stageLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: widget.compact ? 12 : 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: widget.compact ? 10 : 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Fortschrittsbalken
          _buildStageDevelopmentProgress(stageKey),

          // Darstellung der Brut
          if (!widget.compact && count > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildStageVisualizer(
                  stageKey,
                  count,
                  icon,
                  color,
                  scaleFactor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Baut einen Fortschrittsbalken für die Entwicklung eines Stadiums
  Widget _buildStageDevelopmentProgress(String stageKey) {
    double progressValue;
    Color progressColor;

    // Progresswerte basierend auf dem Stadium festlegen
    switch (stageKey) {
      case 'eggs':
        progressValue = _calculateDevelopmentProgress(AntLifeStage.egg);
        progressColor = AppColors.amber;
        break;
      case 'larvae':
        progressValue = _calculateDevelopmentProgress(AntLifeStage.larva);
        progressColor = AppColors.secondary;
        break;
      case 'pupae':
        progressValue = _calculateDevelopmentProgress(AntLifeStage.pupa);
        progressColor = AppColors.primary;
        break;
      default:
        progressValue = 0.0;
        progressColor = Colors.grey;
    }

    return Stack(
      children: [
        // Fortschrittsbalken
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: widget.compact ? 4 : 6,
        ),

        // Trenner bei 25%, 50% und 75%
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => Container(
                width: 1,
                height: widget.compact ? 4 : 6,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Berechnet den Fortschritt der Entwicklung für ein Stadium
  double _calculateDevelopmentProgress(AntLifeStage stage) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentTick = gameProvider.time;

    // Bestimmt den Entwicklungszyklus basierend auf dem Stadium
    int cycleTicks;
    switch (stage) {
      case AntLifeStage.egg:
        cycleTicks = 15; // Entwicklungsdauer eines Eis
        break;
      case AntLifeStage.larva:
        cycleTicks = 20; // Entwicklungsdauer einer Larve
        break;
      case AntLifeStage.pupa:
        cycleTicks = 25; // Entwicklungsdauer einer Puppe
        break;
      default:
        return 0.0;
    }

    // Aktueller Tickstand im Entwicklungszyklus (0 bis cycleTicks-1)
    final currentCycleTick = currentTick % cycleTicks;

    // Fortschritt als Dezimalwert zwischen 0.0 und 1.0
    return currentCycleTick / cycleTicks;
  }

  /// Ruft die Anzahl der Pflegeameisen ab
  int _getCaregiverCount(GameProvider gameProvider) {
    final totalWorkers = gameProvider.resources.population['workers'] ?? 0;
    final caregivingPercentage = gameProvider.taskAllocation.caregiving / 100;
    return (totalWorkers * caregivingPercentage).round();
  }

  /// Baut eine Visualisierung der Brut
  Widget _buildStageVisualizer(
    String stageKey,
    int count,
    IconData icon,
    Color color,
    double scaleFactor,
  ) {
    // Begrenze die Anzahl der anzuzeigenden Symbole auf maximal 10
    final displayCount = min(count, 10);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: List.generate(displayCount, (index) {
            final randomScale = 0.8 + _random.nextDouble() * 0.4; // 0.8 - 1.2
            final individualScaleFactor = scaleFactor * randomScale;

            return Transform.scale(
              scale: individualScaleFactor,
              child: Icon(icon, color: color.withOpacity(0.8), size: 16),
            );
          }),
        );
      },
    );
  }

  /// Baut eine Pflegeameise an einer bestimmten Position
  Widget _buildCaretakerAnt(_CaretakerAnt ant) {
    return Positioned(
      left: ant.position.dx - ant.size / 2,
      top: ant.position.dy - ant.size / 2,
      width: ant.size,
      height: ant.size,
      child: Container(
        decoration: BoxDecoration(color: ant.color, shape: BoxShape.circle),
        child: Center(
          child: Container(
            width: ant.size * 0.5,
            height: ant.size * 0.3,
            decoration: BoxDecoration(
              color:
                  ant.targetIndex == 0
                      ? AppColors
                          .amber // Arbeitet mit Eiern
                      : ant.targetIndex == 1
                      ? AppColors
                          .secondary // Arbeitet mit Larven
                      : AppColors.primary, // Arbeitet mit Puppen
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 1,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Information über die nächste Entwicklungsphase
  Widget _buildNextDevelopmentInfo(GameProvider gameProvider) {
    final currentTick = gameProvider.time;

    // Berechnet, wie viele Ticks bis zur nächsten Entwicklung
    final eggCycle = 15;
    final larvaCycle = 20;
    final pupaCycle = 25;

    final ticksToNextEgg = eggCycle - (currentTick % eggCycle);
    final ticksToNextLarva = larvaCycle - (currentTick % larvaCycle);
    final ticksToNextPupa = pupaCycle - (currentTick % pupaCycle);

    final nextEvent = [
      ticksToNextEgg,
      ticksToNextLarva,
      ticksToNextPupa,
    ].reduce(min);
    String nextEventDescription = '';

    if (nextEvent == ticksToNextEgg) {
      nextEventDescription = 'Eier schlüpfen';
    } else if (nextEvent == ticksToNextLarva) {
      nextEventDescription = 'Larven verpuppen sich';
    } else {
      nextEventDescription = 'Puppen schlüpfen';
    }

    return Text(
      'Nächste Entwicklung: $nextEventDescription in $nextEvent Ticks',
      style: TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
        color: Colors.grey.shade700,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Klasse zur Repräsentation einer Pflegeameise
class _CaretakerAnt {
  final Offset position;
  final int targetIndex; // 0=Eier, 1=Larven, 2=Puppen
  final double size;
  final Color color;

  _CaretakerAnt({
    required this.position,
    required this.targetIndex,
    required this.size,
    required this.color,
  });

  _CaretakerAnt copyWith({
    Offset? position,
    int? targetIndex,
    double? size,
    Color? color,
  }) {
    return _CaretakerAnt(
      position: position ?? this.position,
      targetIndex: targetIndex ?? this.targetIndex,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }
}
