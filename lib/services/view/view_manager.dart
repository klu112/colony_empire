import 'package:flutter/material.dart';

/// Enum für die verschiedenen Ansichten im Spiel
enum GameView {
  /// Nestansicht (unterirdisch)
  NEST,

  /// Oberweltansicht (Oberflächenlebensraum)
  SURFACE,
}

/// Manager für die Spielansichten
/// Steuert den Wechsel zwischen Nest- und Oberweltansicht
class ViewManager with ChangeNotifier {
  /// Aktuelle Ansicht
  GameView _currentView = GameView.NEST;

  /// Animation Controller für den Übergang
  AnimationController? _transitionController;

  /// Animation für den Übergang zwischen Ansichten
  Animation<double>? _transitionAnimation;

  /// Getter für die aktuelle Ansicht
  GameView get currentView => _currentView;

  /// Getter für den Animationswert (0.0 bis 1.0)
  double get transitionValue =>
      _transitionAnimation?.value ??
      (_currentView == GameView.NEST ? 0.0 : 1.0);

  /// Prüft, ob gerade eine Übergangsanimation läuft
  bool get isTransitioning =>
      _transitionController != null && _transitionController!.isAnimating;

  /// Initialisiert den ViewManager mit einem AnimationController
  void initialize(AnimationController controller) {
    _transitionController = controller;
    _transitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController!, curve: Curves.easeInOut),
    );

    // Rücksetzen des Controllers auf die aktuelle Ansicht
    _transitionController!.value = _currentView == GameView.NEST ? 0.0 : 1.0;

    // Listener für Animation Updates
    _transitionController!.addListener(() {
      notifyListeners();
    });
  }

  /// Wechselt zur angegebenen Ansicht mit Animation
  void switchToView(GameView view) {
    if (_currentView == view || _transitionController == null) return;

    _currentView = view;

    // Animation starten
    if (view == GameView.SURFACE) {
      _transitionController!.forward();
    } else {
      _transitionController!.reverse();
    }

    notifyListeners();
  }

  /// Baut das Nest-Exit Widget, das beim Klick zur Oberwelt wechselt
  Widget buildNestExit(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => switchToView(GameView.SURFACE),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue.withOpacity(0.8),
                Colors.brown.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_upward, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Zur Oberfläche',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Baut das Nest-Entrance Widget, das beim Klick zurück zum Nest wechselt
  Widget buildSurfaceEntrance(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () => switchToView(GameView.NEST),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_downward, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Zurück zum Nest',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Erzeugt eine animierte Überblendung zwischen den Ansichten
  Widget buildViewTransition({
    required Widget nestView,
    required Widget surfaceView,
  }) {
    if (_transitionAnimation == null) {
      // Fallback ohne Animation
      return _currentView == GameView.NEST ? nestView : surfaceView;
    }

    return AnimatedBuilder(
      animation: _transitionAnimation!,
      builder: (context, child) {
        return Stack(
          children: [
            // Nestansicht (wird ausgeblendet bei Übergang zur Oberfläche)
            Opacity(opacity: 1 - _transitionAnimation!.value, child: nestView),

            // Oberfläche (wird eingeblendet)
            Opacity(opacity: _transitionAnimation!.value, child: surfaceView),
          ],
        );
      },
    );
  }

  /// Räumt Ressourcen auf
  void dispose() {
    // AnimationController wird nicht hier disposed, da er extern erstellt wurde
    _transitionController = null;
    _transitionAnimation = null;
  }
}
