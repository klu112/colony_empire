import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../providers/game_provider.dart';
import '../../utils/constants/game_enums.dart';
import '../../services/game_manager.dart';
import '../../providers/services_provider.dart';
import '../../models/chamber/chamber_model.dart'; // Add this to fix Chamber references
import '../../models/chamber/tunnel_model.dart'; // Add this to fix Tunnel references
import '../../services/view/view_manager.dart';

// Comment out imports that may not exist yet and replace with stubs for now
//import '../ui/queen_status_indicator_widget.dart';
//import '../ui/build_progress_indicator_widget.dart';
//import 'nursery_view_widget.dart';
//import 'surface_view_widget.dart';

class NestViewWidget extends StatefulWidget {
  const NestViewWidget({super.key});

  @override
  _NestViewWidgetState createState() => _NestViewWidgetState();
}

class _NestViewWidgetState extends State<NestViewWidget> {
  GameView _currentView = GameView.NEST;

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final servicesProvider = Provider.of<ServicesProvider>(context);

    // Get screen size for proper initialization
    final screenSize = MediaQuery.of(context).size;

    // Initialize GameManager with screen size if needed
    if (servicesProvider.initialized && servicesProvider.gameManager != null) {
      if (!servicesProvider.gameManager!.initialized) {
        servicesProvider.gameManager!.initialize(screenSize: screenSize);
      }
    }

    return Container(
      color: Colors.brown[200], // Soil background color
      child: Stack(
        children: [
          // Choose the appropriate view
          _currentView == GameView.NEST
              ? _buildNestView(gameProvider, servicesProvider)
              : _buildSurfaceView(), // Create a stub method instead
          // Add the queen status indicator - replaced with a simple stub widget
          Positioned(
            top: 20,
            left: 20,
            child: _buildQueenStatusIndicator(gameProvider),
          ),

          // View switching button
          Positioned(
            top: 20,
            right: 70,
            child: FloatingActionButton(
              mini: true,
              child: Icon(
                _currentView == GameView.NEST ? Icons.landscape : Icons.home,
              ),
              onPressed: () {
                setState(() {
                  _currentView =
                      _currentView == GameView.NEST
                          ? GameView.SURFACE
                          : GameView.NEST;
                });
                // Also notify the GameManager about the view change
                if (servicesProvider.gameManager != null) {
                  servicesProvider.gameManager!.switchView(_currentView);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Temporary stubs for widgets that don't exist yet
  Widget _buildQueenStatusIndicator(GameProvider gameProvider) {
    // Simple stub for the queen status indicator
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 18),
          SizedBox(width: 4),
          Text(
            'Königin',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSurfaceView() {
    // Placeholder for the surface view
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green[800]!, width: 2),
        ),
        child: const Text(
          'Oberflächen-Ansicht\n(In Entwicklung)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNurseryViewStub() {
    // Placeholder for the nursery view
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[800]!, width: 1),
      ),
      child: const Center(
        child: Text(
          'Brutpflege',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProgressIndicatorStub(Chamber chamber) {
    // Placeholder for the build progress indicator
    final progress = chamber.constructionProgress;
    return Container(
      width: 50,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _buildNestView(
    GameProvider gameProvider,
    ServicesProvider servicesProvider,
  ) {
    return Stack(
      children: [
        // Basic nest drawing - chambers and tunnels
        CustomPaint(
          size: Size.infinite,
          painter: NestPainter(gameProvider.chambers, gameProvider.tunnels),
        ),

        // Ants visualization
        for (final ant in gameProvider.ants)
          Positioned(
            left: ant.position.x - 3,
            top: ant.position.y - 3,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _getAntColor(ant.type, ant.task),
                shape: BoxShape.circle,
              ),
            ),
          ),

        // Pheromone visualization if GameManager is initialized
        if (servicesProvider.gameManager != null &&
            servicesProvider.gameManager!.initialized)
          servicesProvider.gameManager!.getPheromoneVisualization(),

        // Nursery View for eggs and larvae
        Positioned(
          bottom: 20,
          right: 20,
          width: 150,
          height: 150,
          child: _buildNurseryViewStub(), // Use our stub instead
        ),

        // Construction progress indicators
        for (final chamber in gameProvider.chambers)
          if (chamber.state == ChamberState.BUILDING)
            Positioned(
              left: chamber.position.x - 25,
              top: chamber.position.y - 40,
              child: _buildProgressIndicatorStub(
                chamber,
              ), // Use our stub instead
            ),
      ],
    );
  }

  Color _getAntColor(String type, String? task) {
    if (type == 'queen') return Colors.purple;

    switch (task) {
      case 'foraging':
        return Colors.green;
      case 'building':
        return Colors.orangeAccent;
      case 'caregiving':
        return Colors.lightBlue;
      case 'defense':
        return Colors.red;
      case 'exploration':
        return Colors.amber;
      default:
        return Colors.black87;
    }
  }
}

class NestPainter extends CustomPainter {
  final List<Chamber> chambers;
  final List<Tunnel> tunnels;

  NestPainter(this.chambers, this.tunnels);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.brown[700]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    // Draw tunnels
    for (final tunnel in tunnels) {
      final fromChamber = chambers.firstWhere((c) => c.id == tunnel.from);
      final toChamber = chambers.firstWhere((c) => c.id == tunnel.to);

      canvas.drawLine(
        Offset(fromChamber.position.x, fromChamber.position.y),
        Offset(toChamber.position.x, toChamber.position.y),
        paint,
      );
    }

    // Draw chambers
    for (final chamber in chambers) {
      final chamberPaint =
          Paint()
            ..color = _getChamberColor(chamber.type)
            ..style =
                chamber.state == ChamberState.COMPLETED
                    ? PaintingStyle.fill
                    : PaintingStyle.stroke
            ..strokeWidth = 2.0;

      canvas.drawCircle(
        Offset(chamber.position.x, chamber.position.y),
        chamber.size * 15.0,
        chamberPaint,
      );
    }
  }

  Color _getChamberColor(String type) {
    switch (type) {
      case 'queen':
        return Colors.purple[200]!;
      case 'nursery':
        return Colors.blue[200]!;
      case 'storage':
        return Colors.amber[200]!;
      case 'foraging':
        return Colors.green[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
