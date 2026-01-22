import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/bus_connection.dart';
import '../../providers/cpu_simulator_state.dart';
import 'bus_widget.dart';

/// A layer that renders all bus connections between components.
///
/// This widget should be placed behind all CPU components in a Stack.
class BusLayer extends StatefulWidget {
  const BusLayer({super.key});

  @override
  State<BusLayer> createState() => _BusLayerState();
}

class _BusLayerState extends State<BusLayer> {
  final GlobalKey _layerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<CpuSimulatorState>(
      builder: (context, cpuState, child) {
        return Positioned.fill(
          key: _layerKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (cpuState.busConnections.isEmpty) {
                return const SizedBox.shrink();
              }

              // We need to rebuild after layout to get correct positions
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });

              return Stack(
                children: cpuState.busConnections.map((connection) {
                  final positions = _calculatePositions(cpuState, connection);
                  if (positions == null) return const SizedBox.shrink();

                  return Positioned.fill(
                    child: BusWidget(
                      key: ValueKey(connection.id),
                      connection: connection,
                      sourcePosition: positions.$1,
                      targetPosition: positions.$2,
                      numericSystem: cpuState.numericSystem,
                      onAnimationComplete: () {
                        cpuState.completeBusAnimation(connection.id);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  /// Calculate positions relative to this layer
  (Offset, Offset)? _calculatePositions(
    CpuSimulatorState cpuState,
    BusConnection connection,
  ) {
    final layerBox = _layerKey.currentContext?.findRenderObject() as RenderBox?;
    if (layerBox == null) return null;

    final sourcePos = _getLocalPosition(cpuState, connection.source, layerBox);
    final targetPos = _getLocalPosition(cpuState, connection.target, layerBox);

    if (sourcePos == null || targetPos == null) return null;

    return (sourcePos, targetPos);
  }

  /// Get the position of an endpoint relative to this layer
  Offset? _getLocalPosition(
    CpuSimulatorState cpuState,
    BusEndpoint endpoint,
    RenderBox layerBox,
  ) {
    final componentKey = cpuState.getComponentKey(endpoint.componentId);
    if (componentKey == null) return null;

    final componentBox =
        componentKey.currentContext?.findRenderObject() as RenderBox?;
    if (componentBox == null) return null;

    final relativePosition = FieldPositionRegistry.getFieldPosition(endpoint);
    if (relativePosition == null) return null;

    // Convert relative position (0-1) to local position within component
    final componentSize = componentBox.size;
    final localInComponent = Offset(
      relativePosition.dx * componentSize.width,
      relativePosition.dy * componentSize.height,
    );

    // Convert component-local to global, then to layer-local
    final globalPos = componentBox.localToGlobal(localInComponent);
    return layerBox.globalToLocal(globalPos);
  }
}
