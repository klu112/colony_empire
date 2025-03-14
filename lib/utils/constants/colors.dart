import 'package:flutter/material.dart';

/// Das Farbschema für die gesamte Anwendung
class AppColors {
  // App-Basisfarben
  static const Color background = Color(0xFFF5F0E8);
  static const Color surface = Color(0xFFE8DFD5);
  static const Color primary = Color(0xFF8B5E3C);
  static const Color secondary = Color(0xFF3C8B5E);
  static const Color accent = Color(0xFF5E3C8B);
  static const Color error = Color(0xFFC53030);

  // Text
  static const Color textPrimary = Color(0xFF2C2417);
  static const Color textSecondary = Color(0xFF5A4A34);
  static const Color textLight = Color(0xFFF7F2EA);

  // Spezielle UI-Elemente
  static const Color cardBackground = Color(0xFFFAF7F2);
  static const Color divider = Color(0xFFD2C5B8);
  static const Color shadow = Color(0x40000000);

  // Ameisenarten
  static const Color attaGreen = Color(0xFF4D9E50);
  static const Color attaLightGreen = Color(0xFFE0F5E0);
  static const Color oecophyllaYellow = Color(0xFFE0C050);
  static const Color oecophyllaLightYellow = Color(0xFFFAF0D0);
  static const Color ecitonRed = Color(0xFFD14A4A);
  static const Color ecitonLightRed = Color(0xFFF8D7D7);
  static const Color solenopsisOrange = Color(0xFFFF8C42);
  static const Color solenopsisLightOrange = Color(0xFFFFE5D6);

  // Ressourcenfarben
  static const Color food = Color(0xFF66BB6A);
  static const Color buildingMaterials = Color(0xFF8D6E63);
  static const Color water = Color(0xFF42A5F5);
  static const Color danger = Color(0xFFF44336);

  // Aufgabenfarben
  static const Color foraging = Color(0xFF66BB6A);
  static const Color building = Color(0xFFFFB74D);
  static const Color caregiving = Color(0xFFF06292);
  static const Color defense = Color(0xFFF44336);
  static const Color exploration = Color(0xFF42A5F5);

  // Tunnelfarbe
  static const Color tunnel = Color(0xFF8B5A2B);

  // Kammertyp-Farben
  static const Map<String, Color> chamberColors = {
    'queen': Color(0xFFCE93D8),
    'nursery': Color(0xFFF48FB1),
    'storage': Color(0xFFFFD54F),
    'waste': Color(0xFFBDBDBD),
    'defense': Color(0xFFEF9A9A),
  };
  // andere Farben
  static const Color amber = Color(0xFFFFC107);
}
