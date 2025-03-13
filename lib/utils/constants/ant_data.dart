import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

/// Daten und Definitionen für verschiedene Ameisentypen
class AntData {
  static Map<String, Map<String, dynamic>> types = {
    'queen': {
      'name': 'Königin',
      'color': AppColors.attaGreen,
      'size': AppDimensions.antSizeQueen,
      'speed': 0, // Bewegt sich nicht
      'foodConsumption': 0.2,
      'description': 'Legt Eier und führt die Kolonie an.',
    },
    'worker': {
      'name': 'Arbeiterin',
      'color': Colors.brown,
      'size': AppDimensions.antSizeWorker,
      'speed': 2.0,
      'foodConsumption': 0.05,
      'description': 'Erledigt verschiedene Aufgaben in der Kolonie.',
    },
    'soldier': {
      'name': 'Soldatin',
      'color': Colors.red,
      'size': AppDimensions.antSizeSoldier,
      'speed': 1.5,
      'foodConsumption': 0.1,
      'description': 'Spezialisiert auf Verteidigung der Kolonie.',
    },
    'scout': {
      'name': 'Kundschafterin',
      'color': Colors.blue,
      'size': AppDimensions.antSizeScout,
      'speed': 3.0,
      'foodConsumption': 0.05,
      'description': 'Erkundet die Umgebung und findet Ressourcen.',
    },
  };

  static Map<String, dynamic> getTypeInfo(String type) {
    return types[type] ?? types['worker']!;
  }

  static Map<String, Color> taskColors = {
    'foraging': AppColors.foraging,
    'building': AppColors.building,
    'caregiving': AppColors.caregiving,
    'defense': AppColors.defense,
    'exploration': AppColors.exploration,
  };

  static Color getColorForTask(String? task) {
    return task != null ? taskColors[task] ?? Colors.brown : Colors.brown;
  }

  static double getSizeForType(String type) {
    return types[type]?['size'] ?? AppDimensions.antSizeWorker;
  }
}
