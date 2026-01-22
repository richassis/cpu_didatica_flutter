import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cpu_simulator_state.dart';
import '../../utils/number_formatter.dart';

/// Dialog for configuring GPR (General Purpose Registers) inputs.
///
/// Allows setting read addresses A/B, write address, write data,
/// write enable, and triggering clock or reset.
class GprDialog extends StatefulWidget {
  const GprDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const GprDialog(),
    );
  }

  @override
  State<GprDialog> createState() => _GprDialogState();
}

class _GprDialogState extends State<GprDialog> {
  final _readAddressAController = TextEditingController();
  final _readAddressBController = TextEditingController();
  final _writeAddressController = TextEditingController();
  final _writeDataController = TextEditingController();
  bool _writeEnable = false;

  @override
  void initState() {
    super.initState();
    final cpuState = context.read<CpuSimulatorState>();
    final gprBank = cpuState.gprBank;
    final numSys = cpuState.numericSystem;

    _readAddressAController.text = gprBank.readAddressA != null
        ? NumberFormatter.format(
            gprBank.readAddressA!,
            system: numSys,
            showPrefix: false,
          )
        : '';
    _readAddressBController.text = gprBank.readAddressB != null
        ? NumberFormatter.format(
            gprBank.readAddressB!,
            system: numSys,
            showPrefix: false,
          )
        : '';
    _writeAddressController.text = gprBank.writeAddress != null
        ? NumberFormatter.format(
            gprBank.writeAddress!,
            system: numSys,
            showPrefix: false,
          )
        : '';
    _writeDataController.text = gprBank.writeData != null
        ? NumberFormatter.format(
            gprBank.writeData!,
            system: numSys,
            showPrefix: false,
          )
        : '';
    _writeEnable = gprBank.writeEnable ?? false;
  }

  @override
  void dispose() {
    _readAddressAController.dispose();
    _readAddressBController.dispose();
    _writeAddressController.dispose();
    _writeDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cpuState = context.watch<CpuSimulatorState>();
    final gprBank = cpuState.gprBank;
    final numSys = cpuState.numericSystem;

    return AlertDialog(
      title: const Text('GPR Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Read Address A
            TextField(
              controller: _readAddressAController,
              decoration: InputDecoration(
                labelText: 'Read Address A',
                border: const OutlineInputBorder(),
                hintText: '0-${gprBank.registerCount - 1}',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = NumberFormatter.parse(value, context: numSys);
                cpuState.setGprReadAddressA(parsed);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Read Data A: ${NumberFormatter.formatNullable(gprBank.readDataA, system: numSys)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Read Address B
            TextField(
              controller: _readAddressBController,
              decoration: InputDecoration(
                labelText: 'Read Address B',
                border: const OutlineInputBorder(),
                hintText: '0-${gprBank.registerCount - 1}',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = NumberFormatter.parse(value, context: numSys);
                cpuState.setGprReadAddressB(parsed);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Read Data B: ${NumberFormatter.formatNullable(gprBank.readDataB, system: numSys)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Write Address
            TextField(
              controller: _writeAddressController,
              decoration: InputDecoration(
                labelText: 'Write Address',
                border: const OutlineInputBorder(),
                hintText: '0-${gprBank.registerCount - 1}',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = NumberFormatter.parse(value, context: numSys);
                cpuState.setGprWriteAddress(parsed);
              },
            ),
            const SizedBox(height: 16),

            // Write Data
            TextField(
              controller: _writeDataController,
              decoration: const InputDecoration(
                labelText: 'Write Data',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = NumberFormatter.parse(value, context: numSys);
                cpuState.setGprWriteData(parsed);
              },
            ),
            const SizedBox(height: 16),

            // Write Enable switch
            SwitchListTile(
              title: const Text('Write Enable'),
              value: _writeEnable,
              onChanged: (value) {
                setState(() => _writeEnable = value);
                cpuState.setGprWriteEnable(value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      cpuState.clockGpr();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Clock'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      cpuState.resetGpr();
                      setState(() {
                        _readAddressAController.clear();
                        _readAddressBController.clear();
                        _writeAddressController.clear();
                        _writeDataController.clear();
                        _writeEnable = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Register values display
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Register Values',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildRegisterTable(gprBank, numSys),
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

  Widget _buildRegisterTable(gprBank, NumericSystem numSys) {
    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Reg', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Value',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ...gprBank.registers.map<TableRow>((reg) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(reg.name),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(NumberFormatter.format(reg.value, system: numSys)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
