import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Builds a visual representation of a CPU component.
///
/// [type] determines which component to render ('ula', 'memory', 'GPR', etc.)
/// [isActive] controls the visual state (highlighted vs inactive)
Widget buildCpuComponent(BuildContext context, String type, bool isActive) {
  //AVALIAR UTILIZAÇÃO DO RIVE: https://editor.rive.app/home
  final colorScheme = Theme.of(context).colorScheme;
  final svgPath = switch (type) {
    'ula' => 'assets/images/ula_white.svg',
    'memory' => 'assets/images/ula_white.svg',
    _ => 'assets/images/ula_white.svg',
  };
  final color = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

  final component = switch (type) {
    'ula' => Padding(
      padding: const EdgeInsets.all(0.0),
      child: SvgPicture.asset(
        svgPath,
        width: 100,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    ),
    _ => Padding(
      padding: const EdgeInsets.all(0.0),
      child: SizedBox(
        height: 240,
        width: 150,
        child: Card.filled(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: []),
          ),
        ),
      ),
    ),
  };

  return AnimatedContainer(
    duration: Duration(seconds: 5),
    decoration: isActive
        ? BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          )
        : null,
    child: component,
  );
}
