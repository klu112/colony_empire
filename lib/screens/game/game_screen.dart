import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/services_provider.dart';
import '../../utils/constants/game_enums.dart';
import '../../widgets/game/game_controls_widget.dart';
import '../../widgets/game/game_sidebar_widget.dart';
import '../../widgets/game/nest_view_widget.dart';
import '../../widgets/ui/notification_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();

    // Initialisiere Services nach dem Build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final servicesProvider = Provider.of<ServicesProvider>(
        context,
        listen: false,
      );
      servicesProvider.initialize(context);

      // Starte Game Loop, wenn nicht pausiert
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (gameProvider.speed > 0) {
        servicesProvider.gameLoopService.startGameLoop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                // Hauptspielfeld
                Row(
                  children: [
                    // Nestansicht
                    Expanded(
                      child: Stack(
                        children: [
                          // Nestansicht
                          const NestViewWidget(),

                          // Spielsteuerung
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Spielsteuerung (Pause, Play, Fast)
                                const GameControlsWidget(),

                                // Zeit-Anzeige
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Tag ${(gameProvider.time / 20).floor() + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Seitenleiste
                    const GameSidebarWidget(),
                  ],
                ),

                // Benachrichtigungen
                if (gameProvider.notification != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 280, // Berücksichtige Seitenleiste
                    child: NotificationWidget(
                      message: gameProvider.notification!,
                      onDismiss: () => gameProvider.setNotification(null),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Stoppe Game Loop beim Verlassen des Screens
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );
    servicesProvider.gameLoopService.stopGameLoop();
    super.dispose();
  }
}
