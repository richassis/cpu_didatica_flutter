import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cpu_simulator_state.dart';
import '../utils/number_formatter.dart';
import '../widgets/bus/bus_layer.dart';
import '../widgets/components/gpr_component.dart';
import '../widgets/components/ula_component.dart';
import '../widgets/dialogs/dialogs.dart';

/// The main simulator page that displays the CPU components and their connections.
///
/// This page shows a visual representation of a CPU with:
/// - General Purpose Registers (GPR)
/// - Arithmetic Logic Unit (ULA)
/// - Bus connections between components
class SimulatorPage extends StatelessWidget {
  const SimulatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CpuSimulatorState>(
      builder: (context, cpuState, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // const BusLayer(),
              // CPU Components
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GPR Component
                    GprComponent(
                      key: cpuState.gprKey,
                      gprBank: cpuState.gprBank,
                      isActive: cpuState.isComponentActive('gpr'),
                      onTap: () => GprDialog.show(context),
                      numericSystem: cpuState.numericSystem,
                    ),
                    const SizedBox(width: 50),
                    // ULA Component
                    UlaComponent(
                      key: cpuState.ulaKey,
                      ulaState: cpuState.ulaState,
                      isActive: cpuState.isComponentActive('ula'),
                      onTap: () => UlaDialog.show(context),
                    ),
                  ],
                ),
              ),
              const BusLayer(),
              // Numeric System Selector
              Positioned(
                top: 16,
                right: 16,
                child: _NumericSystemSelector(
                  value: cpuState.numericSystem,
                  onChanged: cpuState.setNumericSystem,
                ),
              ),

              // Left side controls
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    // Clock Button
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: IconButton(
                        icon: Icon(
                          Icons.play_arrow,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        tooltip: 'Clock (Execute cycle)',
                        onPressed: cpuState.clockAll,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bus Connection Button
                    Card(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cable),
                            tooltip: 'Create Bus Connection',
                            onPressed: () => BusConnectionDialog.show(context),
                          ),
                          if (cpuState.busConnections.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Badge(
                                label: Text(
                                  '${cpuState.busConnections.length}',
                                ),
                                child: const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget for selecting the numeric system (Hex, Dec, Bin).
class _NumericSystemSelector extends StatelessWidget {
  const _NumericSystemSelector({required this.value, required this.onChanged});

  final NumericSystem value;
  final ValueChanged<NumericSystem> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.numbers, size: 20),
            const SizedBox(width: 8),
            SegmentedButton<NumericSystem>(
              segments: NumericSystem.values.map((sys) {
                return ButtonSegment<NumericSystem>(
                  value: sys,
                  label: Text(NumberFormatter.label(sys)),
                );
              }).toList(),
              selected: {value},
              onSelectionChanged: (selected) {
                onChanged(selected.first);
              },
              style: ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
      ),
    );
  }
}
