import 'package:flutter/material.dart';

/// Abstract base class for all CPU components.
///
/// Provides common behavior for layout, animations, and state management
/// while allowing each component to define its own visual design.
abstract class CpuComponent extends StatelessWidget {
  const CpuComponent({super.key, required this.isActive, this.onTap});

  /// Whether this component is currently active in the simulation
  final bool isActive;

  /// Optional callback when the component is tapped
  final VoidCallback? onTap;

  /// Override this to provide the component's unique visual design.
  ///
  /// [context] - Build context for accessing theme and other inherited widgets
  /// [activeColor] - Color to use when component is active
  /// [inactiveColor] - Color to use when component is inactive
  Widget buildComponentDesign(
    BuildContext context, {
    required Color activeColor,
    required Color inactiveColor,
  });

  /// The duration of the activation animation
  Duration get animationDuration => const Duration(milliseconds: 300);

  /// Override to customize the glow effect when active
  BoxDecoration? buildActiveDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.5),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant;

    final component = buildComponentDesign(
      context,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: animationDuration,
        decoration: isActive ? buildActiveDecoration(context) : null,
        child: component,
      ),
    );
  }
}
