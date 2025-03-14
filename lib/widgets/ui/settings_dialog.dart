import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/services_provider.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/text_styles.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _musicVolume = 0.7;
  double _effectsVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : AppDimensions.l),
        width: isSmallScreen ? double.infinity : 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Einstellungen',
              style:
                  isSmallScreen
                      ? const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                      : AppTextStyles.heading2,
            ),
            const SizedBox(height: 24),

            // Sound aktivieren
            SwitchListTile(
              title: const Text('Sound aktivieren'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),

            // Vibration aktivieren
            SwitchListTile(
              title: const Text('Vibration aktivieren'),
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),

            const SizedBox(height: 16),

            // Musik-Lautstärke
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Musik-Lautstärke'),
                ),
                Slider(
                  value: _musicVolume,
                  onChanged: (value) {
                    setState(() {
                      _musicVolume = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),

            // Effekt-Lautstärke
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Effekt-Lautstärke'),
                ),
                Slider(
                  value: _effectsVolume,
                  onChanged: (value) {
                    setState(() {
                      _effectsVolume = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Abbrechen'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Hier die Einstellungen speichern
                    // servicesProvider.saveSettings(...)
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Speichern'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
