import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/bus_connection.dart';
import '../../providers/cpu_simulator_state.dart';
import '../../utils/number_formatter.dart';

/// Dialog for creating a bus connection between two component fields.
class BusConnectionDialog extends StatefulWidget {
  const BusConnectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const BusConnectionDialog(),
    );
  }

  @override
  State<BusConnectionDialog> createState() => _BusConnectionDialogState();
}

class _BusConnectionDialogState extends State<BusConnectionDialog> {
  BusEndpoint? _sourceEndpoint;
  BusEndpoint? _targetEndpoint;

  @override
  Widget build(BuildContext context) {
    final cpuState = context.watch<CpuSimulatorState>();
    final numSys = cpuState.numericSystem;

    // Use the dedicated source/target endpoint lists
    final sourceEndpoints = FieldPositionRegistry.sourceEndpoints;

    // Filter target endpoints to exclude the source
    final targetEndpoints = FieldPositionRegistry.targetEndpoints.where((e) {
      if (_sourceEndpoint != null && e == _sourceEndpoint) return false;
      return true;
    }).toList();

    return AlertDialog(
      title: const Text('Create Bus Connection'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source selection
            Text(
              'Source (data from):',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<BusEndpoint>(
              value: _sourceEndpoint,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select source field',
              ),
              items: sourceEndpoints.map((endpoint) {
                final value = cpuState.getFieldValue(endpoint);
                final valueStr = value != null
                    ? ' = ${NumberFormatter.format(value, system: numSys)}'
                    : '';
                return DropdownMenuItem(
                  value: endpoint,
                  child: Text('${endpoint.key}$valueStr'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _sourceEndpoint = value;
                  // Reset target if same as source
                  if (_targetEndpoint == value) {
                    _targetEndpoint = null;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            // Target selection
            Text(
              'Target (data to):',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<BusEndpoint>(
              value: _targetEndpoint,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select target field',
              ),
              items: targetEndpoints.map((endpoint) {
                return DropdownMenuItem(
                  value: endpoint,
                  child: Text(endpoint.key),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _targetEndpoint = value);
              },
            ),
            const SizedBox(height: 24),

            // Preview
            if (_sourceEndpoint != null && _targetEndpoint != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text('Preview:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sourceEndpoint!.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            NumberFormatter.format(
                              cpuState.getFieldValue(_sourceEndpoint!) ?? 0,
                              system: numSys,
                            ),
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.blue),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _targetEndpoint!.key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(will receive)',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Existing connections
            if (cpuState.busConnections.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Connections:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      cpuState.clearBusConnections();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...cpuState.busConnections.map((conn) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    conn.isAnimating ? Icons.sync : Icons.check_circle,
                    color: conn.isAnimating ? Colors.blue : Colors.green,
                    size: 20,
                  ),
                  title: Text(
                    '${conn.source.key} → ${conn.target.key}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    'Value: ${NumberFormatter.format(conn.value, system: numSys)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () {
                      cpuState.removeBusConnection(conn.id);
                    },
                  ),
                );
              }),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: _sourceEndpoint != null && _targetEndpoint != null
              ? () {
                  cpuState.createBusConnection(
                    _sourceEndpoint!,
                    _targetEndpoint!,
                  );
                  setState(() {
                    _sourceEndpoint = null;
                    _targetEndpoint = null;
                  });
                }
              : null,
          child: const Text('Create Connection'),
        ),
      ],
    );
  }
}
