import 'package:flutter/material.dart';

import '../../models/memory_state.dart';
import '../base/cpu_component_base.dart';

/// Memory component.
///
/// Displays a memory block visualization with address ranges
/// and optional memory content preview.
/// The data comes from [MemoryState] model.
class MemoryComponent extends CpuComponent {
  const MemoryComponent({
    super.key,
    required super.isActive,
    super.onTap,
    required this.memoryState,
    this.label = 'Memory',
    this.height = 240,
    this.width = 150,
  });

  /// The Memory data model
  final MemoryState memoryState;

  /// Label for the memory component
  final String label;

  /// Height of the component
  final double height;

  /// Width of the component
  final double width;

  @override
  Widget buildComponentDesign(
    BuildContext context, {
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final color = isActive ? activeColor : inactiveColor;
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      width: width,
      child: Card.filled(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Spacer(),
              _buildAddressRange(context),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRange(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onPrimary.withValues(alpha: 0.7);

    return Column(
      children: [
        Text(
          '0x${memoryState.startAddress.toRadixString(16).padLeft(4, '0').toUpperCase()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          '...',
          style: theme.textTheme.bodySmall?.copyWith(color: textColor),
        ),
        Text(
          '0x${memoryState.endAddress.toRadixString(16).padLeft(4, '0').toUpperCase()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
