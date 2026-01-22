import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cpu_simulator_state.dart';
import '../../utils/number_formatter.dart';

/// Dialog for configuring Memory operations.
///
/// Allows reading from and writing to memory addresses.
class MemoryDialog extends StatefulWidget {
  const MemoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const MemoryDialog(),
    );
  }

  @override
  State<MemoryDialog> createState() => _MemoryDialogState();
}

class _MemoryDialogState extends State<MemoryDialog> {
  final _readAddressController = TextEditingController();
  final _writeAddressController = TextEditingController();
  final _writeValueController = TextEditingController();

  int? _readResult;
  String? _readError;
  String? _writeError;
  String? _writeSuccess;

  @override
  void dispose() {
    _readAddressController.dispose();
    _writeAddressController.dispose();
    _writeValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cpuState = context.watch<CpuSimulatorState>();
    final memoryState = cpuState.memoryState;
    final numSys = cpuState.numericSystem;

    return AlertDialog(
      title: const Text('Memory Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Memory info
            Text(
              'Size: ${memoryState.size} words (${memoryState.wordSize}-bit)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Read section
            const SizedBox(height: 8),
            Text('Read Memory', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _readAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      hintText: '0-255',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _handleRead, child: const Text('Read')),
              ],
            ),
            if (_readResult != null) ...[
              const SizedBox(height: 8),
              Text(
                'Value: ${NumberFormatter.format(_readResult!, system: numSys)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
              ),
            ],
            if (_readError != null) ...[
              const SizedBox(height: 8),
              Text(
                _readError!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),

            // Write section
            const SizedBox(height: 8),
            Text('Write Memory', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _writeAddressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                hintText: '0-255',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _writeValueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _handleWrite,
                icon: const Icon(Icons.save),
                label: const Text('Write'),
              ),
            ),
            if (_writeSuccess != null) ...[
              const SizedBox(height: 8),
              Text(
                _writeSuccess!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.green.shade700),
              ),
            ],
            if (_writeError != null) ...[
              const SizedBox(height: 8),
              Text(
                _writeError!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),

            // Non-zero entries display
            const SizedBox(height: 8),
            Text(
              'Non-Zero Entries',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildNonZeroTable(memoryState, numSys),
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

  void _handleRead() {
    final cpuState = context.read<CpuSimulatorState>();
    final numSys = cpuState.numericSystem;
    final address = NumberFormatter.parse(
      _readAddressController.text,
      context: numSys,
    );

    setState(() {
      _readError = null;
      _readResult = null;
    });

    if (address == null) {
      setState(() => _readError = 'Invalid address');
      return;
    }

    try {
      final value = cpuState.readMemory(address);
      setState(() => _readResult = value);
    } on RangeError catch (e) {
      setState(() => _readError = e.message.toString());
    }
  }

  void _handleWrite() {
    final cpuState = context.read<CpuSimulatorState>();
    final numSys = cpuState.numericSystem;
    final address = NumberFormatter.parse(
      _writeAddressController.text,
      context: numSys,
    );
    final value = NumberFormatter.parse(
      _writeValueController.text,
      context: numSys,
    );

    setState(() {
      _writeError = null;
      _writeSuccess = null;
    });

    if (address == null) {
      setState(() => _writeError = 'Invalid address');
      return;
    }

    if (value == null) {
      setState(() => _writeError = 'Invalid value');
      return;
    }

    try {
      cpuState.writeMemory(address, value);
      setState(() => _writeSuccess = 'Wrote $value to address $address');
    } on RangeError catch (e) {
      setState(() => _writeError = e.message.toString());
    }
  }

  Widget _buildNonZeroTable(memoryState, NumericSystem numSys) {
    final entries = memoryState.nonZeroEntries;

    if (entries.isEmpty) {
      return const Text(
        'All memory locations are zero.',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Addr',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
        ...entries.map<TableRow>((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(NumberFormatter.format(entry.key, system: numSys)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  NumberFormatter.format(entry.value, system: numSys),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
