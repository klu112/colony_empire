import 'package:flutter/material.dart';

class SpeciesSelectionScreen extends StatelessWidget {
  const SpeciesSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colony Empire'),
      ),
      body: const Center(
        child: Text('Speziesauswahl folgt in Kürze!'),
      ),
    );
  }
}