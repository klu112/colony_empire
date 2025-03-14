import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/services_provider.dart';
import '../../utils/constants/game_enums.dart';
import '../../widgets/game/game_controls_widget.dart';
import '../../widgets/game/game_sidebar_widget.dart';
import '../../widgets/game/nest_view_widget.dart';
import '../../widgets/ui/notification_widget.dart';
import '../../widgets/game/pause_menu_widget.dart';
import '../../utils/constants/colors.dart';
import '../../widgets/game/collapsible_sidebar_widget.dart';
import '../../widgets/ui/settings_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isPaused = false;
  late _LifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();

    print('GameScreen: initState');

    // Initialisiere Services nach dem Build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('GameScreen: PostFrameCallback');
      final servicesProvider = Provider.of<ServicesProvider>(
        context,
        listen: false,
      );
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      servicesProvider.initialize(
        gameProvider,
      ); // Fix: use gameProvider instead of casting context

      // Starte Game Loop, wenn nicht pausiert
      if (gameProvider.speed > 0) {
        print('Starting game loop with speed: ${gameProvider.speed}');
        servicesProvider.gameLoopService.startGameLoop();
      }
    });
  }

  // Ändere in der build-Methode die Seitenleiste
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

                          // Pause-Button
                          Positioned(
                            top: 16,
                            right: 16,
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.white.withOpacity(0.8),
                              foregroundColor: AppColors.primary,
                              child: const Icon(Icons.pause),
                              onPressed: () {
                                setState(() {
                                  _isPaused = true;
                                });
                                // Spiel pausieren
                                final servicesProvider =
                                    Provider.of<ServicesProvider>(
                                      context,
                                      listen: false,
                                    );
                                servicesProvider.setGameSpeed(0);
                                gameProvider.setGameState(GameState.paused);
                              },
                            ),
                          ),

                          Positioned(
                            top: 16,
                            right: 16 + 48, // Platz für den Pause-Button lassen
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Colors.white.withOpacity(0.8),
                              foregroundColor: AppColors.primary,
                              child: const Icon(Icons.settings),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const SettingsDialog(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Klappbare Seitenleiste statt fester Sidebar
                    const CollapsibleSidebarWidget(),
                  ],
                ),

                // Benachrichtigungen
                if (gameProvider.notification != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    // Use relative positioning instead of fixed pixels
                    right:
                        MediaQuery.of(context).size.width < 600
                            ? 0
                            : MediaQuery.of(context).size.width *
                                0.25, // Responsive sidebar width
                    child: NotificationWidget(
                      message: gameProvider.notification!,
                      onDismiss: () => gameProvider.setNotification(null),
                    ),
                  ),

                // Pause-Menü
                if (_isPaused)
                  GestureDetector(
                    onTap: () {}, // Verhindere Klicks durch das Menü
                    child: PauseMenuWidget(
                      onResume: () {
                        setState(() {
                          _isPaused = false;
                        });
                      },
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
    print('GameScreen: dispose');
    // Stoppe Game Loop beim Verlassen des Screens
    if (mounted) {
      final servicesProvider = Provider.of<ServicesProvider>(
        context,
        listen: false,
      );
      servicesProvider.gameLoopService.stopGameLoop();
    }
    super.dispose();
  }
}

/// Hilfklasse zum Beobachten des App-Lifecycle-Status
class _LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback? onPause;
  final VoidCallback? onResume;

  _LifecycleObserver({this.onPause, this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && onPause != null) {
      onPause!();
    } else if (state == AppLifecycleState.resumed && onResume != null) {
      onResume!();
    }
  }
}
