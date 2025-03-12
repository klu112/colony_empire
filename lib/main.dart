import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/species_selection.dart';
import 'providers/game_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Colony Empire',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          useMaterial3: true,
          fontFamily: 'GameFont',
        ),
        home: const SpeciesSelectionScreen(),
      ),
    );
  }
}