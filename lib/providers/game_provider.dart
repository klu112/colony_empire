import 'package:flutter/foundation.dart';

class GameProvider with ChangeNotifier {
  // Basisimplementierung - wird später erweitert
  String _gameState = 'selection';
  Map<String, dynamic> _resources = {};
  String? _selectedSpecies;

  // Getter
  String get gameState => _gameState;
  Map<String, dynamic> get resources => _resources;
  String? get selectedSpecies => _selectedSpecies;

  // Setter mit Benachrichtigung
  void setGameState(String newState) {
    _gameState = newState;
    notifyListeners();
  }

  void setSelectedSpecies(String species) {
    _selectedSpecies = species;
    notifyListeners();
  }
}