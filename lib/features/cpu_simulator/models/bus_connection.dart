import 'package:flutter/material.dart';

/// Identifies a specific field on a CPU component that can be connected via a bus.
class BusEndpoint {
  const BusEndpoint({required this.componentId, required this.fieldId});

  /// The component identifier (e.g., 'gpr', 'ula', 'memory')
  final String componentId;

  /// The field identifier within the component (e.g., 'readDataA', 'operandA')
  final String fieldId;

  /// Creates a unique key for this endpoint
  String get key => '$componentId.$fieldId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusEndpoint &&
          runtimeType == other.runtimeType &&
          componentId == other.componentId &&
          fieldId == other.fieldId;

  @override
  int get hashCode => componentId.hashCode ^ fieldId.hashCode;

  @override
  String toString() => key;
}

/// Represents a bus connection between two component fields.
class BusConnection {
  BusConnection({
    required this.source,
    required this.target,
    required this.value,
    this.isAnimating = true,
  }) : id = '${source.key}->${target.key}';

  /// Unique identifier for this connection
  final String id;

  /// The source endpoint (where data comes from)
  final BusEndpoint source;

  /// The target endpoint (where data goes to)
  final BusEndpoint target;

  /// The value being transferred
  final int value;

  /// Whether the bus is currently animating
  final bool isAnimating;

  /// Create a copy with updated fields
  BusConnection copyWith({
    BusEndpoint? source,
    BusEndpoint? target,
    int? value,
    bool? isAnimating,
  }) {
    return BusConnection(
      source: source ?? this.source,
      target: target ?? this.target,
      value: value ?? this.value,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

/// Registry of field positions for a component.
///
/// Each component should define a static map of field IDs to their
/// relative positions within the component widget.
class FieldPositionRegistry {
  FieldPositionRegistry._();

  /// GPR field positions (relative to component top-left, 0-1 range)
  static const Map<String, Offset> gprFields = {
    // Input fields (left side)
    'readAddressA': Offset(0.0, 0.25),
    'readAddressB': Offset(0.0, 0.40),
    'writeAddress': Offset(0.0, 0.55),
    'writeData': Offset(0.0, 0.70),
    'writeEnable': Offset(0.0, 0.85),
    // Output fields (right side)
    'readDataA': Offset(1.0, 0.35),
    'readDataB': Offset(1.0, 0.55),
  };

  /// ULA field positions (relative to component top-left, 0-1 range)
  static const Map<String, Offset> ulaFields = {
    // Input fields (left side)
    'operandA': Offset(0.0, 0.35),
    'operandB': Offset(0.0, 0.65),
    // Output fields (right side)
    'result': Offset(1.0, 0.5),
  };

  /// Memory field positions (relative to component top-left)
  static const Map<String, Offset> memoryFields = {
    'address': Offset(0.0, 0.3),
    'writeData': Offset(0.0, 0.6),
    'readData': Offset(1.0, 0.5),
  };

  /// Source fields (output fields that can provide data)
  static const List<BusEndpoint> sourceEndpoints = [
    BusEndpoint(componentId: 'gpr', fieldId: 'readDataA'),
    BusEndpoint(componentId: 'gpr', fieldId: 'readDataB'),
    BusEndpoint(componentId: 'ula', fieldId: 'result'),
  ];

  /// Target fields (input fields that can receive data)
  static const List<BusEndpoint> targetEndpoints = [
    BusEndpoint(componentId: 'gpr', fieldId: 'readAddressA'),
    BusEndpoint(componentId: 'gpr', fieldId: 'readAddressB'),
    BusEndpoint(componentId: 'gpr', fieldId: 'writeAddress'),
    BusEndpoint(componentId: 'gpr', fieldId: 'writeData'),
    BusEndpoint(componentId: 'gpr', fieldId: 'writeEnable'),
    BusEndpoint(componentId: 'ula', fieldId: 'operandA'),
    BusEndpoint(componentId: 'ula', fieldId: 'operandB'),
  ];

  /// Get field positions for a component
  static Map<String, Offset>? getFieldsForComponent(String componentId) {
    return switch (componentId) {
      'gpr' => gprFields,
      'ula' => ulaFields,
      'memory' => memoryFields,
      _ => null,
    };
  }

  /// Get the relative position for a specific endpoint
  static Offset? getFieldPosition(BusEndpoint endpoint) {
    final fields = getFieldsForComponent(endpoint.componentId);
    return fields?[endpoint.fieldId];
  }

  /// Get all available endpoints for display in UI
  static List<BusEndpoint> getAllEndpoints() {
    final endpoints = <BusEndpoint>[];

    for (final fieldId in gprFields.keys) {
      endpoints.add(BusEndpoint(componentId: 'gpr', fieldId: fieldId));
    }
    for (final fieldId in ulaFields.keys) {
      endpoints.add(BusEndpoint(componentId: 'ula', fieldId: fieldId));
    }
    for (final fieldId in memoryFields.keys) {
      endpoints.add(BusEndpoint(componentId: 'memory', fieldId: fieldId));
    }

    return endpoints;
  }
}
