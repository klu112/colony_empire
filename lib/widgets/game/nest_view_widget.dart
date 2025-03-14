import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ant/ant_model.dart';
import '../../models/chamber/chamber_model.dart';
import '../../models/chamber/tunnel_model.dart';
import '../../providers/game_provider.dart';
import '../ant/ant_widget.dart';
import '../chamber/chamber_widget.dart';
import '../chamber/tunnel_widget.dart';
import 'nest_background_widget.dart';

class NestViewWidget extends StatelessWidget {
  const NestViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Bildschirmgrößen abrufen für Skalierung
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    // Skalierungsfaktor berechnen basierend auf Bildschirmgröße
    // Verwende kleineren Wert von Breite oder Höhe
    final screenMinDimension =
        size.width < size.height ? size.width : size.height;
    final scaleFactor =
        isSmallScreen
            ? screenMinDimension /
                600 // Referenzgröße
            : 1.0;

    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final List<Chamber> chambers = gameProvider.chambers;
        final List<Tunnel> tunnels = gameProvider.tunnels;
        final List<Ant> ants = gameProvider.ants;
        final int? selectedChamberId = gameProvider.selectedChamberId;

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 2.0,
          child: SizedBox(
            // Container mit fester Größe für das Nest
            width: 400,
            height: 400,
            child: Stack(
              children: [
                // Hintergrund
                const NestBackgroundWidget(),

                // Tunnel
                ...tunnels.map(
                  (tunnel) => TunnelWidget(
                    tunnel: tunnel,
                    chambers: chambers,
                    scaleFactor: scaleFactor,
                  ),
                ),

                // Kammern
                ...chambers.map(
                  (chamber) => ChamberWidget(
                    chamber: chamber,
                    isSelected: chamber.id == selectedChamberId,
                    onTap:
                        () => gameProvider.selectChamber(
                          chamber.id == selectedChamberId ? null : chamber.id,
                        ),
                    scaleFactor: scaleFactor,
                  ),
                ),

                // Ameisen
                ...ants.map(
                  (ant) => AntWidget(ant: ant, scaleFactor: scaleFactor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
