import 'package:flutter/material.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/dimensions.dart';
import '../utils/constants/text_styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spielhilfe'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : AppDimensions.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spielübersicht',
              style:
                  isSmallScreen
                      ? const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                      : AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            const Text(
              'In Colony Empire übernimmst du die Kontrolle über eine wachsende Ameisenkolonie. '
              'Dein Ziel ist es, eine florierende Zivilisation aufzubauen, indem du Ressourcen '
              'sammelst, Kammern baust und deine Bevölkerung verwaltest.',
            ),

            const SizedBox(height: 24),

            Text(
              'Steuerung',
              style:
                  isSmallScreen
                      ? const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                      : AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            _buildHelpItem(
              icon: Icons.touch_app,
              title: 'Kammer auswählen',
              description:
                  'Tippe auf eine Kammer, um sie auszuwählen und weitere Informationen anzuzeigen.',
            ),
            _buildHelpItem(
              icon: Icons.build,
              title: 'Kammer bauen',
              description:
                  'Wähle im Seitenmenü unter "Kammern bauen" den gewünschten Kammertyp aus.',
            ),
            _buildHelpItem(
              icon: Icons.speed,
              title: 'Spielgeschwindigkeit',
              description:
                  'Nutze die Steuerelemente unten links, um das Spiel zu pausieren, '
                  'in normaler oder erhöhter Geschwindigkeit fortzusetzen.',
            ),

            const SizedBox(height: 24),

            Text(
              'Ressourcen & Aufgaben',
              style:
                  isSmallScreen
                      ? const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                      : AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            _buildHelpItem(
              icon: Icons.grass,
              title: 'Nahrung',
              description:
                  'Wird für das Wachstum der Kolonie benötigt. Erhöhe den Anteil der '
                  'Nahrungssuche, um mehr Nahrung zu sammeln.',
            ),
            _buildHelpItem(
              icon: Icons.foundation,
              title: 'Baumaterial',
              description:
                  'Wird zum Bau neuer Kammern benötigt. Erhöhe den Anteil des Nestbaus, '
                  'um mehr Baumaterial zu sammeln.',
            ),
            _buildHelpItem(
              icon: Icons.water_drop,
              title: 'Wasser',
              description:
                  'Wichtig für die Gesundheit der Kolonie. Wird automatisch während '
                  'der Nahrungssuche gesammelt.',
            ),

            const SizedBox(height: 24),

            Text(
              'Tipps & Tricks',
              style:
                  isSmallScreen
                      ? const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                      : AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            const Text(
              '• Balanciere die Aufgabenverteilung basierend auf aktuellen Bedürfnissen.\n'
              '• Baue verschiedene Kammertypen, um die Effizienz deiner Kolonie zu verbessern.\n'
              '• Achte auf die Fähigkeiten deiner gewählten Ameisenart.\n'
              '• Reagiere auf Ereignisse, die während des Spiels auftreten.\n'
              '• Bei Ressourcenknappheit fokussiere dich zuerst auf Nahrung und Wasser.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
