import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Erweitert StatelessWidget um Performance-Optimierungen
mixin StatelessDebug on StatelessWidget {
  /// Debug-Option für Widgets zur Messung von Build-Zeiten
  @override
  StatelessElement createElement() {
    if (kDebugMode) {
      debugPrint('Building $runtimeType');
    }
    return StatelessLogElement(this);
  }
}

/// Element mit Build-Zeit-Messung
class StatelessLogElement extends StatelessElement {
  StatelessLogElement(StatelessWidget widget) : super(widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      super.mount(parent, newSlot);
      debugPrint('$widget mounted in ${stopwatch.elapsedMilliseconds}ms');
    } else {
      super.mount(parent, newSlot);
    }
  }

  @override
  void update(StatelessWidget newWidget) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      super.update(newWidget);
      debugPrint('$widget updated in ${stopwatch.elapsedMilliseconds}ms');
    } else {
      super.update(newWidget);
    }
  }
}

/// Extension auf BuildContext für leichteren Zugriff auf Provider
extension BuildContextExtension on BuildContext {
  /// Get MediaQuery data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;
}
