import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/services_provider.dart';
import 'screens/species_selection.dart';
import 'utils/constants/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Wichtig: ServicesProvider muss vor GameProvider kommen
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        // Verbindung zwischen den Providern herstellen
        ProxyProvider2<ServicesProvider, GameProvider, void>(
          update: (_, servicesProvider, gameProvider, __) {
            if (gameProvider != null && servicesProvider != null) {
              // 1. GameProvider über ServicesProvider informieren
              gameProvider.updateServicesProvider(servicesProvider);
              // 2. Initialisiere ServicesProvider wenn nötig
              if (!servicesProvider.initialized &&
                  !servicesProvider.initializing) {
                servicesProvider.initialize(gameProvider);
              }
            }
            return;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Colony Empire',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            background: AppColors.background,
            error: AppColors.error,
          ),
          scaffoldBackgroundColor: AppColors.background,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            // Weitere TextStyles hier...
          ),
          cardTheme: CardTheme(
            color: AppColors.cardBackground,
            elevation: 2,
            shadowColor: AppColors.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
        ),
        home: const SpeciesSelectionScreen(),
      ),
    );
  }
}
