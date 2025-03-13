import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/colony_model.dart';

/// Repository-Klasse für Persistenz des Spielstands
class ColonyRepository {
  static const String _saveKey = 'colony_empire_save';

  /// Speichere Kolonie in SharedPreferences
  Future<bool> saveColony(Colony colony) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(colony.toJson());
      return await prefs.setString(_saveKey, jsonString);
    } catch (e) {
      // In einer echten App würden wir hier Logging verwenden
      print('Error saving colony: $e');
      return false;
    }
  }

  /// Lade Kolonie aus SharedPreferences
  Future<Colony?> loadColony() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_saveKey);

      if (jsonString == null) {
        return null;
      }

      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return Colony.fromJson(map);
    } catch (e) {
      // In einer echten App würden wir hier Logging verwenden
      print('Error loading colony: $e');
      return null;
    }
  }

  /// Lösche gespeicherten Spielstand
  Future<bool> deleteColonySave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_saveKey);
    } catch (e) {
      print('Error deleting colony save: $e');
      return false;
    }
  }

  /// Prüfe, ob ein Spielstand existiert
  Future<bool> hasSavedColony() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_saveKey);
    } catch (e) {
      print('Error checking for saved colony: $e');
      return false;
    }
  }
}
