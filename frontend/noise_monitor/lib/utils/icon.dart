import 'package:flutter/material.dart';

class SensorIcon extends StatelessWidget {
  const SensorIcon({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    if (active) {
      return Icon(
        Icons.sensors,
        color: color,
      );
    }
    return Icon(
      Icons.sensors_off,
      color: color.withAlpha(85),
    );
  }
}
