import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/number_formatter.dart';

/// State management for the CPU Simulator.
///
/// Manages active component tracking, GlobalKeys for positioning,
/// and the data state of all CPU components.
class CpuSimulatorState extends ChangeNotifier {
  CpuSimulatorState();

  // ============ Component Keys (for positioning/painting) ============
  final GlobalKey gprKey = GlobalKey();
  final GlobalKey ulaKey = GlobalKey();
  final GlobalKey memoryKey = GlobalKey();
  final GlobalKey pcKey = GlobalKey();

  // ============ Display Settings ============
  NumericSystem _numericSystem = NumericSystem.hex;

  NumericSystem get numericSystem => _numericSystem;

  void setNumericSystem(NumericSystem system) {
    if (_numericSystem != system) {
      _numericSystem = system;
      notifyListeners();
    }
  }

  // ============ Active Component Tracking ============
  String? _activeComponentId;

  String? get activeComponentId => _activeComponentId;

  bool isComponentActive(String componentId) {
    return _activeComponentId == componentId;
  }

  void setActiveComponent(String? componentId) {
    if (_activeComponentId != componentId) {
      _activeComponentId = componentId;
      notifyListeners();
    }
  }

  void toggleComponent(String componentId) {
    if (_activeComponentId == componentId) {
      _activeComponentId = null;
    } else {
      _activeComponentId = componentId;
    }
    notifyListeners();
  }

  void clearActiveComponent() {
    setActiveComponent(null);
  }

  // Legacy getter for backward compatibility
  bool get isUlaActive => isComponentActive('ula');

  void toggleUla() => toggleComponent('ula');

  // ============ CPU Component Data State ============
  GprBank _gprBank = GprBank();
  UlaState _ulaState = const UlaState();
  MemoryState _memoryState = MemoryState();
  int _programCounter = 0;

  // Getters
  GprBank get gprBank => _gprBank;
  UlaState get ulaState => _ulaState;
  MemoryState get memoryState => _memoryState;
  int get programCounter => _programCounter;

  // ============ GPR Operations ============
  void updateRegister(int address, int value) {
    _gprBank = _gprBank.updateRegister(address, value);
    notifyListeners();
  }

  void setGprReadAddressA(int? address) {
    _gprBank = _gprBank.withReadAddressA(address);
    notifyListeners();
  }

  void setGprReadAddressB(int? address) {
    _gprBank = _gprBank.withReadAddressB(address);
    notifyListeners();
  }

  void setGprWriteAddress(int? address) {
    _gprBank = _gprBank.withWriteAddress(address);
    notifyListeners();
  }

  void setGprWriteData(int? data) {
    _gprBank = _gprBank.withWriteData(data);
    notifyListeners();
  }

  void setGprWriteEnable(bool? enable) {
    _gprBank = _gprBank.withWriteEnable(enable);
    notifyListeners();
  }

  void clockGpr() {
    _gprBank = _gprBank.clock();
    notifyListeners();
  }

  void resetGpr() {
    _gprBank = _gprBank.reset();
    notifyListeners();
  }

  // ============ ULA Operations ============
  void setUlaOperandA(int a) {
    _ulaState = _ulaState.withOperandA(a);
    notifyListeners();
  }

  void setUlaOperandB(int b) {
    _ulaState = _ulaState.withOperandB(b);
    notifyListeners();
  }

  void setUlaOperands(int a, int b) {
    _ulaState = _ulaState.withOperands(a, b);
    notifyListeners();
  }

  void setUlaOperation(UlaOperation operation) {
    _ulaState = _ulaState.withOperation(operation);
    notifyListeners();
  }

  void clockUla() {
    _ulaState = _ulaState.clock();
    notifyListeners();
  }

  // ============ Memory Operations ============
  int readMemory(int address) {
    return _memoryState.read(address);
  }

  void writeMemory(int address, int value) {
    _memoryState = _memoryState.write(address, value);
    notifyListeners();
  }

  // ============ Program Counter Operations ============
  void setProgramCounter(int value) {
    _programCounter = value;
    notifyListeners();
  }

  void incrementProgramCounter() {
    _programCounter++;
    notifyListeners();
  }

  // ============ Global Clock ============
  /// Clock all components: triggers bus transfers, then clocks GPR and ULA
  void clockAll() {
    // First, clock the bus to transfer values
    clockBus();

    // Then clock the components
    _gprBank = _gprBank.clock();
    _ulaState = _ulaState.clock();
    _programCounter++;

    notifyListeners();
  }

  // ============ Reset ============
  void reset() {
    _gprBank = GprBank();
    _ulaState = const UlaState();
    _memoryState = MemoryState();
    _programCounter = 0;
    _activeComponentId = null;
    _busConnections.clear();
    notifyListeners();
  }

  // ============ Bus Connections ============
  final List<BusConnection> _busConnections = [];

  List<BusConnection> get busConnections => List.unmodifiable(_busConnections);

  /// Get the value from a component field
  int? getFieldValue(BusEndpoint endpoint) {
    return switch (endpoint.componentId) {
      'gpr' => _getGprFieldValue(endpoint.fieldId),
      'ula' => _getUlaFieldValue(endpoint.fieldId),
      'memory' => null, // Memory needs address context
      _ => null,
    };
  }

  int? _getGprFieldValue(String fieldId) {
    return switch (fieldId) {
      'readDataA' => _gprBank.readDataA,
      'readDataB' => _gprBank.readDataB,
      'readAddressA' => _gprBank.readAddressA,
      'readAddressB' => _gprBank.readAddressB,
      'writeAddress' => _gprBank.writeAddress,
      'writeData' => _gprBank.writeData,
      _ => null,
    };
  }

  int? _getUlaFieldValue(String fieldId) {
    return switch (fieldId) {
      'operandA' => _ulaState.operandA,
      'operandB' => _ulaState.operandB,
      'result' => _ulaState.result,
      _ => null,
    };
  }

  /// Set a value to a component field
  void setFieldValue(BusEndpoint endpoint, int value) {
    switch (endpoint.componentId) {
      case 'gpr':
        _setGprFieldValue(endpoint.fieldId, value);
        break;
      case 'ula':
        _setUlaFieldValue(endpoint.fieldId, value);
        break;
    }
  }

  void _setGprFieldValue(String fieldId, int value) {
    switch (fieldId) {
      case 'readAddressA':
        setGprReadAddressA(value);
        break;
      case 'readAddressB':
        setGprReadAddressB(value);
        break;
      case 'writeAddress':
        setGprWriteAddress(value);
        break;
      case 'writeData':
        setGprWriteData(value);
        break;
    }
  }

  void _setUlaFieldValue(String fieldId, int value) {
    switch (fieldId) {
      case 'operandA':
        setUlaOperandA(value);
        break;
      case 'operandB':
        setUlaOperandB(value);
        break;
    }
  }

  /// Create a new bus connection (does not transfer value until clock)
  void createBusConnection(BusEndpoint source, BusEndpoint target) {
    final sourceValue = getFieldValue(source);
    if (sourceValue == null) return;

    // Create the connection (not animating yet, waits for clock)
    final connection = BusConnection(
      source: source,
      target: target,
      value: sourceValue,
      isAnimating: false,
    );

    _busConnections.add(connection);
    notifyListeners();
  }

  /// Trigger clock for all bus connections - starts animation and transfers values
  void clockBus() {
    for (var i = 0; i < _busConnections.length; i++) {
      final conn = _busConnections[i];

      // Get fresh value from source
      final sourceValue = getFieldValue(conn.source);
      if (sourceValue == null) continue;

      // Update connection to animate with current value
      _busConnections[i] = conn.copyWith(value: sourceValue, isAnimating: true);

      // Transfer value to target
      setFieldValue(conn.target, sourceValue);
    }
    notifyListeners();
  }

  /// Mark a bus connection animation as complete
  void completeBusAnimation(String connectionId) {
    final index = _busConnections.indexWhere((c) => c.id == connectionId);
    if (index != -1) {
      _busConnections[index] = _busConnections[index].copyWith(
        isAnimating: false,
      );
      notifyListeners();
    }
  }

  /// Remove a bus connection
  void removeBusConnection(String connectionId) {
    _busConnections.removeWhere((c) => c.id == connectionId);
    notifyListeners();
  }

  /// Clear all bus connections
  void clearBusConnections() {
    _busConnections.clear();
    notifyListeners();
  }

  /// Get the GlobalKey for a component
  GlobalKey? getComponentKey(String componentId) {
    return switch (componentId) {
      'gpr' => gprKey,
      'ula' => ulaKey,
      'memory' => memoryKey,
      _ => null,
    };
  }
}
