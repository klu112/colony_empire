# Colony Empire

Ein Ameisen-Aufbau-Simulationsspiel entwickelt mit Flutter.

## Beschreibung

Colony Empire ist eine Aufbau-Simulation, in der Spieler eine Ameisenkolonie von einer einzelnen Königin bis zu einer florierenden Zivilisation aufbauen. Wähle zwischen vier einzigartigen Ameisenarten, jede mit speziellen Fähigkeiten.

## Entwicklungseinrichtung

1. Stelle sicher, dass Flutter installiert ist:
2. Abhängigkeiten installieren:
3. App ausführen:

## Features

- Verschiedene Ameisenarten mit einzigartigen Fähigkeiten
- Modularer Nestbau mit verschiedenen Kammern
- Ressourcenmanagement und Aufgabenzuweisung
- Dynamisches Ökosystem mit Events und Herausforderungen

## Projektstruktur
lib/
├── main.dart                # App-Einstiegspunkt
├── models/                  # Datenmodelle
│   ├── ant/                 # Ameisen-Modelle
│   ├── chamber/             # Kammer- und Tunnel-Modelle
│   ├── species/             # Ameisenarten-Modelle
│   ├── resources/           # Ressourcen- und Aufgabenmodelle
│   └── colony_model.dart    # Hauptspielzustand
├── providers/               # State Management
│   └── game_provider.dart   # Zentraler GameProvider
├── screens/                 # UI-Screens
│   ├── species_selection.dart  # Artenauswahl
│   ├── tutorial_screen.dart    # Tutorial
│   └── game/                   # Spielbildschirme
├── widgets/                 # Wiederverwendbare UI-Komponenten
│   ├── ant/                 # Ameisen-Widgets
│   ├── chamber/             # Kammer-Widgets
│   ├── resources/           # Ressourcen-Widgets
│   └── ui/                  # Allgemeine UI-Widgets
├── services/                # Spiellogik und Services
│   └── ...                  # Wird in Phase 3 implementiert
└── utils/                   # Hilfsfunktionen
└── constants/           # Spielkonstanten und -daten

## Fortschritt

- ✅ Phase 1: Einrichtung der Entwicklungsumgebung
- ✅ Phase 2: Architektur und Design
- 🔄 Phase 3: Datenmodelle und State Management (In Arbeit)
- ⬜ Phase 4: UI-Komponenten
- ⬜ Phase 5: Spiellogik
- ⬜ Phase 6: Persistenz und Optimierung
- ⬜ Phase 7: Testen und Polishing
- ⬜ Phase 8: Deployment und Release