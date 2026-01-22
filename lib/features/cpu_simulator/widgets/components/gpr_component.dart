import 'package:flutter/material.dart';

import '../../models/gpr_bank.dart';
import '../../utils/number_formatter.dart';
import '../base/cpu_component_base.dart';

/// GPR (General Purpose Registers) component.
///
/// Displays a card-based register bank.
/// The data comes from [GprBank] model - this widget only handles presentation.
class GprComponent extends CpuComponent {
  const GprComponent({
    super.key,
    required super.isActive,
    super.onTap,
    required this.gprBank,
    this.height = 240,
    this.width = 150,
    this.numericSystem = NumericSystem.hex,
  });

  /// The GPR data model containing register values
  final GprBank gprBank;

  /// Height of the component
  final double height;

  /// Width of the component
  final double width;

  /// The numeric system for displaying values
  final NumericSystem numericSystem;

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
                'GPR',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildRegisterList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterList(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onPrimary.withValues(alpha: 0.8);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: gprBank.registerCount,
      itemBuilder: (context, index) {
        final register = gprBank[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                register.name,
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
              Text(
                NumberFormatter.format(register.value, system: numericSystem),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
