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
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final List<Chamber> chambers = gameProvider.chambers;
        final List<Tunnel> tunnels = gameProvider.tunnels;
        final List<Ant> ants = gameProvider.ants;
        final int? selectedChamberId = gameProvider.selectedChamberId;

        return Stack(
          children: [
            // Hintergrund
            const NestBackgroundWidget(),

            // Tunnel
            ...tunnels.map(
              (tunnel) => TunnelWidget(tunnel: tunnel, chambers: chambers),
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
              ),
            ),

            // Ameisen
            ...ants.map((ant) => AntWidget(ant: ant)),
          ],
        );
      },
    );
  }
}
