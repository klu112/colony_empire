import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/resources/task_allocation_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

/// Widget zum Zuweisen von Ameisen zu verschiedenen Aufgaben.
class TaskAssignmentPanelWidget extends StatefulWidget {
  /// Gibt an, ob das Panel kompakt angezeigt werden soll.
  final bool compact;

  /// Erstellt ein neues TaskAssignmentPanel.
  const TaskAssignmentPanelWidget({super.key, this.compact = false});

  @override
  State<TaskAssignmentPanelWidget> createState() =>
      _TaskAssignmentPanelWidgetState();
}

class _TaskAssignmentPanelWidgetState extends State<TaskAssignmentPanelWidget>
    with SingleTickerProviderStateMixin {
  // Controller für Feedback-Animationen
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Speichert die letzte Änderung für visuelles Feedback
  Map<String, bool> _lastChangeDirection = {};

  // Speichert die Aufgaben, die gerade animiert werden
  final Map<String, bool> _animatingTasks = {};

  @override
  void initState() {
    super.initState();

    // Animation für visuelles Feedback einrichten
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Startet eine Animation für visuelles Feedback bei Änderungen
  void _animateChange(String taskName, bool isIncrease) {
    // Speichere Änderungsrichtung für diese Aufgabe
    _lastChangeDirection[taskName] = isIncrease;

    // Markiere die Aufgabe als animierend
    setState(() {
      _animatingTasks[taskName] = true;
    });

    // Animation starten
    _animationController.reset();
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: isIncrease ? 1.2 : 0.8,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        // Animation beenden
        setState(() {
          _animatingTasks[taskName] = false;
        });
      });
    });
  }

  /// Ändert die Zuweisung für eine Aufgabe
  void _changeAssignment(BuildContext context, String taskName, int change) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final taskAllocation = gameProvider.taskAllocation;

    // Aktuelle Zuweisung ermitteln
    int currentValue;
    switch (taskName) {
      case 'foraging':
        currentValue = taskAllocation.foraging;
        break;
      case 'building':
        currentValue = taskAllocation.building;
        break;
      case 'caregiving':
        currentValue = taskAllocation.caregiving;
        break;
      case 'defense':
        currentValue = taskAllocation.defense;
        break;
      case 'exploration':
        currentValue = taskAllocation.exploration;
        break;
      default:
        return;
    }

    // Neue Zuweisung berechnen
    final newValue = (currentValue + change).clamp(0, 100);

    // Nur aktualisieren, wenn sich der Wert ändert
    if (newValue != currentValue) {
      gameProvider.updateTaskAllocation(taskName, newValue);

      // Animation für visuelles Feedback
      _animateChange(taskName, change > 0);
    }
  }

  /// Berechnet die Anzahl der verfügbaren Arbeiter
  int _getAvailableWorkers(GameProvider gameProvider) {
    // Gesamtanzahl der Arbeiter
    final totalWorkers = gameProvider.resources.population['workers'] ?? 0;

    // Bereits zugewiesene Arbeiter (Aufgabenzuweisungen sind Prozente)
    final totalAssigned =
        (gameProvider.taskAllocation.foraging +
            gameProvider.taskAllocation.building +
            gameProvider.taskAllocation.caregiving +
            gameProvider.taskAllocation.defense +
            gameProvider.taskAllocation.exploration) /
        100 *
        totalWorkers;

    // Runde auf die nächste ganze Zahl
    return (totalWorkers - totalAssigned).round();
  }

  /// Berechnet die Anzahl der Arbeiter für eine Aufgabe basierend auf dem Prozentsatz
  int _getWorkersForTask(GameProvider gameProvider, String taskName) {
    final totalWorkers = gameProvider.resources.population['workers'] ?? 0;
    int percentage;

    switch (taskName) {
      case 'foraging':
        percentage = gameProvider.taskAllocation.foraging;
        break;
      case 'building':
        percentage = gameProvider.taskAllocation.building;
        break;
      case 'caregiving':
        percentage = gameProvider.taskAllocation.caregiving;
        break;
      case 'defense':
        percentage = gameProvider.taskAllocation.defense;
        break;
      case 'exploration':
        percentage = gameProvider.taskAllocation.exploration;
        break;
      default:
        percentage = 0;
    }

    return (totalWorkers * percentage / 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final availableWorkers = _getAvailableWorkers(gameProvider);
        final taskAllocation = gameProvider.taskAllocation;
        final totalWorkers = gameProvider.resources.population['workers'] ?? 0;

        // Definiere alle Aufgaben mit Icon, Farbe und Namen
        final tasks = [
          {
            'name': 'foraging',
            'label': 'Nahrungssuche',
            'icon': Icons.grass,
            'color': Colors.green,
            'value': taskAllocation.foraging,
            'workers': _getWorkersForTask(gameProvider, 'foraging'),
          },
          {
            'name': 'building',
            'label': 'Bau',
            'icon': Icons.architecture,
            'color': Colors.amber,
            'value': taskAllocation.building,
            'workers': _getWorkersForTask(gameProvider, 'building'),
          },
          {
            'name': 'caregiving',
            'label': 'Brutpflege',
            'icon': Icons.child_care,
            'color': Colors.lightBlue,
            'value': taskAllocation.caregiving,
            'workers': _getWorkersForTask(gameProvider, 'caregiving'),
          },
          {
            'name': 'defense',
            'label': 'Verteidigung',
            'icon': Icons.security,
            'color': Colors.red,
            'value': taskAllocation.defense,
            'workers': _getWorkersForTask(gameProvider, 'defense'),
          },
          {
            'name': 'exploration',
            'label': 'Erkundung',
            'icon': Icons.explore,
            'color': Colors.purple,
            'value': taskAllocation.exploration,
            'workers': _getWorkersForTask(gameProvider, 'exploration'),
          },
        ];

        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aufgabenzuweisung',
                      style:
                          widget.compact
                              ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )
                              : AppTextStyles.heading3,
                    ),
                    // Anzeige der verfügbaren Arbeiter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            availableWorkers > 0 ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '$availableWorkers verfügbar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Gesamtübersicht
                LinearProgressIndicator(
                  value: 1 - availableWorkers / totalWorkers,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    availableWorkers > 0 ? Colors.blue : Colors.green,
                  ),
                ),

                const SizedBox(height: 16),

                // Aufgabenliste
                ...tasks
                    .map(
                      (task) => _buildTaskRow(
                        context,
                        task['name'] as String,
                        task['label'] as String,
                        task['icon'] as IconData,
                        task['color'] as Color,
                        task['value'] as int,
                        task['workers'] as int,
                        availableWorkers,
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Baut eine einzelne Aufgabenzeile
  Widget _buildTaskRow(
    BuildContext context,
    String taskName,
    String label,
    IconData icon,
    Color color,
    int value,
    int workers,
    int availableWorkers,
  ) {
    // Prüfe, ob diese Aufgabe animiert werden soll
    final bool isAnimating = _animatingTasks[taskName] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Icon für die Aufgabe
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: 12),

          // Aufgabenname und zugewiesene Arbeiter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                // Animierte Anzeige der zugewiesenen Arbeiter
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isAnimating ? _scaleAnimation.value : 1.0,
                      child: Text(
                        '$workers Arbeiter ($value%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Buttons für Erhöhung/Verringerung
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Verringern-Button
              _buildActionButton(
                context,
                Icons.remove,
                () => _changeAssignment(context, taskName, -5),
                value > 0,
                color,
              ),

              // Prozentanzeige
              SizedBox(
                width: 40,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final displayColor =
                        isAnimating
                            ? (_lastChangeDirection[taskName] ?? false
                                ? Colors.green
                                : Colors.red)
                            : Colors.black;

                    return Text(
                      '$value%',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: displayColor,
                      ),
                    );
                  },
                ),
              ),

              // Erhöhen-Button
              _buildActionButton(
                context,
                Icons.add,
                () => _changeAssignment(context, taskName, 5),
                // Nur aktivieren, wenn noch Arbeiter verfügbar sind oder andere Aufgaben reduziert werden können
                availableWorkers > 0 || value < 100,
                color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Baut einen Aktions-Button (Plus/Minus)
  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    bool enabled,
    Color color,
  ) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: enabled ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(4),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? color : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
