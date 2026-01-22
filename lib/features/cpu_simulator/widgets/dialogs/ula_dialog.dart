import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ula_state.dart';
import '../../providers/cpu_simulator_state.dart';
import '../../utils/number_formatter.dart';

/// Dialog for configuring ULA (Arithmetic Logic Unit) inputs.
///
/// Allows setting operand A, operand B, operation type, and triggering clock.
class UlaDialog extends StatefulWidget {
  const UlaDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const UlaDialog(),
    );
  }

  @override
  State<UlaDialog> createState() => _UlaDialogState();
}

class _UlaDialogState extends State<UlaDialog> {
  final _operandAController = TextEditingController();
  final _operandBController = TextEditingController();
  UlaOperation _selectedOperation = UlaOperation.none;

  @override
  void initState() {
    super.initState();
    final cpuState = context.read<CpuSimulatorState>();
    final ulaState = cpuState.ulaState;
    final numSys = cpuState.numericSystem;

    _operandAController.text = NumberFormatter.format(
      ulaState.operandA,
      system: numSys,
      showPrefix: false,
    );
    _operandBController.text = NumberFormatter.format(
      ulaState.operandB,
      system: numSys,
      showPrefix: false,
    );
    _selectedOperation = ulaState.operation;
  }

  @override
  void dispose() {
    _operandAController.dispose();
    _operandBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cpuState = context.watch<CpuSimulatorState>();
    final ulaState = cpuState.ulaState;
    final numSys = cpuState.numericSystem;

    return AlertDialog(
      title: const Text('ULA Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operand A
            TextField(
              controller: _operandAController,
              decoration: const InputDecoration(
                labelText: 'Operand A',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = NumberFormatter.parse(value, context: numSys);
                if (parsed != null) {
                  cpuState.setUlaOperandA(parsed);
                }
              },
            ),
            const SizedBox(height: 16),

            // Operand B
            TextField(
              controller: _operandBController,
              decoration: const InputDecoration(
                labelText: 'Operand B',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = NumberFormatter.parse(value, context: numSys);
                if (parsed != null) {
                  cpuState.setUlaOperandB(parsed);
                }
              },
            ),
            const SizedBox(height: 16),

            // Operation dropdown
            DropdownButtonFormField<UlaOperation>(
              value: _selectedOperation,
              decoration: const InputDecoration(
                labelText: 'Operation',
                border: OutlineInputBorder(),
              ),
              items: UlaOperation.values.map((op) {
                return DropdownMenuItem(
                  value: op,
                  child: Text(_operationName(op)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedOperation = value);
                  cpuState.setUlaOperation(value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Clock button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  cpuState.clockUla();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Clock (Execute)'),
              ),
            ),
            const SizedBox(height: 24),

            // Results display
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Result: ${NumberFormatter.format(ulaState.result, system: numSys)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildFlagsDisplay(ulaState.flags),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildFlagsDisplay(UlaFlags flags) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildFlagChip('Z', flags.zero),
        _buildFlagChip('C', flags.carry),
        _buildFlagChip('N', flags.negative),
        _buildFlagChip('O', flags.overflow),
      ],
    );
  }

  Widget _buildFlagChip(String label, bool active) {
    return Chip(
      label: Text(label),
      backgroundColor: active ? Colors.green.shade100 : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: active ? Colors.green.shade800 : Colors.grey.shade600,
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _operationName(UlaOperation op) {
    return switch (op) {
      UlaOperation.none => 'None',
      UlaOperation.add => 'Add (+)',
      UlaOperation.sub => 'Subtract (-)',
      UlaOperation.and_ => 'AND (&)',
      UlaOperation.or_ => 'OR (|)',
      UlaOperation.xor => 'XOR (^)',
      UlaOperation.not => 'NOT (~)',
      UlaOperation.shl => 'Shift Left (<<)',
      UlaOperation.shr => 'Shift Right (>>)',
    };
  }
}
