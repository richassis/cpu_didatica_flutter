import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/ula_state.dart';
import '../base/cpu_component_base.dart';

/// ULA (Arithmetic Logic Unit) component.
///
/// Displays the ULA using an SVG graphic with color changes
/// based on active state. The data comes from [UlaState] model.
class UlaComponent extends CpuComponent {
  const UlaComponent({
    super.key,
    required super.isActive,
    super.onTap,
    this.ulaState,
    this.width = 100,
  });

  /// The ULA data model (optional - for displaying operation info)
  final UlaState? ulaState;

  /// Width of the ULA SVG
  final double width;

  @override
  Widget buildComponentDesign(
    BuildContext context, {
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final color = isActive ? activeColor : inactiveColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/images/ula_white.svg',
          width: width,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        if (ulaState != null && ulaState!.operation != UlaOperation.none)
          _buildOperationInfo(context),
      ],
    );
  }

  Widget _buildOperationInfo(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface.withValues(alpha: 0.8);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Text(
            _operationToString(ulaState!.operation),
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Result: 0x${ulaState!.result.toRadixString(16).toUpperCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _operationToString(UlaOperation op) {
    return switch (op) {
      UlaOperation.none => '',
      UlaOperation.add => 'ADD',
      UlaOperation.sub => 'SUB',
      UlaOperation.and_ => 'AND',
      UlaOperation.or_ => 'OR',
      UlaOperation.xor => 'XOR',
      UlaOperation.not => 'NOT',
      UlaOperation.shl => 'SHL',
      UlaOperation.shr => 'SHR',
    };
  }

  @override
  BoxDecoration? buildActiveDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // ULA has a circular glow to match its shape
    return BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.5),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    );
  }
}
