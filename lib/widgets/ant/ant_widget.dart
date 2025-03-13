import 'package:flutter/material.dart';
import '../../models/ant/ant_model.dart';
import '../../utils/constants/ant_data.dart';

class AntWidget extends StatelessWidget {
  final Ant ant;

  const AntWidget({super.key, required this.ant});

  @override
  Widget build(BuildContext context) {
    final antInfo = AntData.getTypeInfo(ant.type);
    final size = AntData.getSizeForType(ant.type);

    // Farbe basierend auf Typ oder Aufgabe
    Color color;
    if (ant.type == 'queen') {
      color = Colors.purple;
    } else {
      color = AntData.getColorForTask(ant.task);
    }

    return Positioned(
      left: ant.position.x - size / 2,
      top: ant.position.y - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        // Für komplexere Ants kann hier auch ein CustomPainter verwendet werden
      ),
    );
  }
}
