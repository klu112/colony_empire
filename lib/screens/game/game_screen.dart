import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Colony Empire')),
      body: const Center(
        child: Text('Hier wird der Hauptspielbildschirm implementiert'),
      ),
    );
  }
}
