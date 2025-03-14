import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/resources/resources_model.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';
import 'dart:math' as math;

/// Widget zur Anzeige des Gesundheits- und Nahrungszustands der Königin
class QueenStatusIndicatorWidget extends StatefulWidget {
  /// Größe des Widgets
  final double size;

  /// Zeigt erweiterte Informationen an, wenn true
  final bool showExtendedInfo;

  /// Erstellt einen neuen QueenStatusIndicator
  const QueenStatusIndicatorWidget({
    Key? key,
    this.size = 120.0,
    this.showExtendedInfo = true,
  }) : super(key: key);

  @override
  State<QueenStatusIndicatorWidget> createState() =>
      _QueenStatusIndicatorWidgetState();
}

class _QueenStatusIndicatorWidgetState extends State<QueenStatusIndicatorWidget>
    with SingleTickerProviderStateMixin {
  // Animation für Pulsieren bei Gefahrenzustand
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation für Warnzustände
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final resources = gameProvider.resources;
        final queenHealth = resources.queenHealth;
        final isStarving = resources.isQueenStarving();

        // Wenn die Königin verhungert, Animation aktivieren
        if (isStarving && !_animationController.isAnimating) {
          _animationController.repeat(reverse: true);
        } else if (!isStarving && _animationController.isAnimating) {
          _animationController.stop();
          _animationController.reset();
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: isStarving ? _pulseAnimation.value : 1.0,
              child: _buildQueenStatusCard(resources),
            );
          },
        );
      },
    );
  }

  /// Baut die Hauptkarte für den Königinnenstatus
  Widget _buildQueenStatusCard(Resources resources) {
    final queenHealth = resources.queenHealth;
    final isStarving = resources.isQueenStarving();
    final isDead = resources.isQueenDead();
    final statusColor = _getStatusColor(queenHealth);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(color: statusColor, width: 2.0),
      ),
      child: Container(
        width: widget.size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, statusColor.withOpacity(0.2)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium - 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Königinnen-Symbol und -Titel
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_nature, color: statusColor, size: 22),
                const SizedBox(width: 4),
                Text(
                  'Königin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDead ? Colors.grey : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Gesundheitsstatus-Anzeige
            _buildHealthIndicator(queenHealth, isStarving, isDead),

            // Zusätzliche Informationen
            if (widget.showExtendedInfo) ...[
              const SizedBox(height: 8),
              _buildExtendedInfo(resources),
            ],

            // Warnmeldungen bei Gefahrenzuständen
            if (isStarving)
              _buildWarningBadge(
                isDead ? 'Königin gestorben!' : 'Königin hungert!',
              ),
          ],
        ),
      ),
    );
  }

  /// Baut die visuelle Gesundheitsanzeige
  Widget _buildHealthIndicator(double health, bool isStarving, bool isDead) {
    final statusColor = _getStatusColor(health);

    return Column(
      children: [
        // Textanzeige des Gesundheitszustands
        Text(
          isDead
              ? 'Gestorben'
              : isStarving
              ? 'Hungert'
              : 'Gesund',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDead ? Colors.grey.shade700 : statusColor,
          ),
        ),
        const SizedBox(height: 4),

        // Kreisförmiger Fortschrittsbalken
        SizedBox(
          height: widget.size * 0.4,
          width: widget.size * 0.4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Kreisförmiger Fortschrittsbalken
              CircularProgressIndicator(
                value: health / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),

              // Queen Icon oder Totenkopf bei Tod
              Icon(
                isDead ? Icons.dangerous : Icons.badge,
                size: widget.size * 0.2,
                color: isDead ? Colors.grey : statusColor,
              ),

              // Numerischer Wert
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    '${health.toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDead ? Colors.grey.shade700 : statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Baut erweiterte Informationen zum Koloniezustand
  Widget _buildExtendedInfo(Resources resources) {
    final eggCount = resources.population['eggs'] ?? 0;
    final larvaeCount = resources.population['larvae'] ?? 0;
    final workerCount = resources.population['workers'] ?? 0;
    final queensHealth = resources.queenHealth;
    final canLayEggs = queensHealth > 30;

    return Column(
      children: [
        Divider(height: 16, thickness: 1, color: Colors.grey.withOpacity(0.3)),

        // Eier-Produktionsstatus
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.egg_alt,
                  size: 14,
                  color: canLayEggs ? Colors.amber : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text('Eierproduktion:', style: TextStyle(fontSize: 12)),
              ],
            ),
            Text(
              canLayEggs ? 'Aktiv' : 'Inaktiv',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: canLayEggs ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Population
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Eier:', style: TextStyle(fontSize: 12)),
            Text(
              '$eggCount',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Larven:', style: TextStyle(fontSize: 12)),
            Text(
              '$larvaeCount',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Arbeiter:', style: TextStyle(fontSize: 12)),
            Text(
              '$workerCount',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  /// Baut ein Warnungs-Badge für kritische Zustände
  Widget _buildWarningBadge(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Bestimmt die Statusfarbe basierend auf der Gesundheit
  Color _getStatusColor(double health) {
    if (health <= 0) {
      return Colors.grey; // Tot
    } else if (health <= 25) {
      return Colors.red; // Kritisch
    } else if (health <= 50) {
      return Colors.orange; // Gefährdet
    } else if (health <= 75) {
      return Colors.amber; // Warnung
    } else {
      return Colors.green; // Gesund
    }
  }
}

/// Kompakte Version des Queen Status Indicators für die Statusleiste
class CompactQueenStatusIndicator extends StatelessWidget {
  /// Größe des kompakten Indikators
  final double size;

  /// Erstellt einen neuen kompakten QueenStatusIndicator
  const CompactQueenStatusIndicator({Key? key, this.size = 40.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final resources = gameProvider.resources;
        final queenHealth = resources.queenHealth;
        final isStarving = resources.isQueenStarving();
        final isDead = resources.isQueenDead();
        final statusColor = _getStatusColor(queenHealth);

        return Tooltip(
          message:
              'Königin: ${queenHealth.toInt()}% Gesundheit' +
              (isStarving ? ' (Hungert!)' : '') +
              (isDead ? ' (Gestorben!)' : ''),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: statusColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color:
                      isStarving
                          ? Colors.red.withOpacity(0.5)
                          : Colors.transparent,
                  blurRadius: 4,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Kreisförmiger Fortschrittsbalken
                Center(
                  child: SizedBox(
                    width: size * 0.8,
                    height: size * 0.8,
                    child: CircularProgressIndicator(
                      value: queenHealth / 100,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),

                // Queen Icon
                Center(
                  child: Icon(
                    isDead ? Icons.dangerous : Icons.emoji_nature,
                    size: size * 0.4,
                    color: statusColor,
                  ),
                ),

                // Warnindikator bei niedrigem Gesundheitszustand
                if (isStarving)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: size * 0.3,
                      height: size * 0.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: size * 0.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bestimmt die Statusfarbe basierend auf der Gesundheit
  Color _getStatusColor(double health) {
    if (health <= 0) {
      return Colors.grey; // Tot
    } else if (health <= 25) {
      return Colors.red; // Kritisch
    } else if (health <= 50) {
      return Colors.orange; // Gefährdet
    } else if (health <= 75) {
      return Colors.amber; // Warnung
    } else {
      return Colors.green; // Gesund
    }
  }
}
