# Bus System Documentation

## CPU Didática Flutter - Bus Connection System

This document provides a comprehensive explanation of the bus connection system implemented in the CPU Didática Flutter application. It covers the architecture, data flow, animation system, position calculation, and how to extend or configure the system.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Key Classes and Files](#key-classes-and-files)
4. [Data Models](#data-models)
   - [BusEndpoint](#busendpoint)
   - [BusConnection](#busconnection)
   - [FieldPositionRegistry](#fieldpositionregistry)
5. [State Management](#state-management)
6. [Widget System](#widget-system)
   - [BusLayer](#buslayer)
   - [BusWidget](#buswidget)
7. [Position Calculation Pipeline](#position-calculation-pipeline)
8. [Animation System](#animation-system)
9. [Data Flow Pipeline](#data-flow-pipeline)
10. [Clock System](#clock-system)
11. [UI Dialog](#ui-dialog)
12. [How to Add New Components](#how-to-add-new-components)
13. [Common Patterns Used](#common-patterns-used)
14. [Troubleshooting](#troubleshooting)

---

## Overview

The bus system simulates the data buses in a CPU, which are the pathways that carry data between different components (like registers, ALU, memory, etc.). In this educational simulator:

- **Bus connections** are visual wires drawn between component fields
- **Data packets** animate along the wires when the clock is triggered
- **Values are transferred** from source fields (outputs) to target fields (inputs)

### Visual Representation

```
┌─────────────────┐                    ┌─────────────────┐
│      GPR        │                    │      ULA        │
│                 │                    │                 │
│   readDataA ●───┼────── BUS ────────►┼── operandA     │
│   readDataB ●───┼────── BUS ────────►┼── operandB     │
│                 │                    │                 │
│                 │     ◄─ BUS ────────┼── result ●     │
│   writeData  ◄──┼────────────────────┼                │
└─────────────────┘                    └─────────────────┘
```

---

## Architecture

The bus system follows a clean separation of concerns:

```
┌─────────────────────────────────────────────────────────────────┐
│                        SimulatorPage                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                         Stack                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │   │
│  │  │ GprComponent│  │ UlaComponent│  │    BusLayer     │   │   │
│  │  │  (GlobalKey)│  │  (GlobalKey)│  │   (overlay)     │   │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘   │   │
│  │                                           │               │   │
│  │                                    ┌──────┴──────┐        │   │
│  │                                    │  BusWidget  │ (×N)   │   │
│  │                                    │  (per conn) │        │   │
│  │                                    └─────────────┘        │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │      CpuSimulatorState        │
              │  (Provider/ChangeNotifier)    │
              │                               │
              │  - busConnections: List<...>  │
              │  - gprKey, ulaKey: GlobalKey  │
              │  - clockAll(), clockBus()     │
              └───────────────────────────────┘
```

### File Structure

```
lib/features/cpu_simulator/
├── models/
│   └── bus_connection.dart     # BusEndpoint, BusConnection, FieldPositionRegistry
├── providers/
│   └── cpu_simulator_state.dart  # State management with bus operations
├── widgets/
│   ├── bus/
│   │   ├── bus_layer.dart      # Overlay that renders all connections
│   │   └── bus_widget.dart     # Individual bus connection with animation
│   └── dialogs/
│       └── bus_connection_dialog.dart  # UI for creating connections
└── pages/
    └── simulator_page.dart     # Main page composing everything
```

---

## Key Classes and Files

| File | Class | Purpose |
|------|-------|---------|
| `bus_connection.dart` | `BusEndpoint` | Identifies a specific field on a component |
| `bus_connection.dart` | `BusConnection` | Represents a connection between two endpoints |
| `bus_connection.dart` | `FieldPositionRegistry` | Stores relative positions of all fields |
| `cpu_simulator_state.dart` | `CpuSimulatorState` | Manages state, GlobalKeys, and operations |
| `bus_layer.dart` | `BusLayer` | Container widget that renders all bus connections |
| `bus_widget.dart` | `BusWidget` | Individual bus with animation and painting |
| `bus_connection_dialog.dart` | `BusConnectionDialog` | Dialog for creating connections |

---

## Data Models

### BusEndpoint

**Location:** `lib/features/cpu_simulator/models/bus_connection.dart`

A `BusEndpoint` uniquely identifies a specific field on a CPU component.

```dart
class BusEndpoint {
  const BusEndpoint({
    required this.componentId,  // e.g., 'gpr', 'ula', 'memory'
    required this.fieldId,      // e.g., 'readDataA', 'operandA'
  });

  final String componentId;
  final String fieldId;

  /// Creates a unique key like "gpr.readDataA"
  String get key => '$componentId.$fieldId';
}
```

**Key Concepts:**
- **`componentId`**: Identifies which component (GPR, ULA, Memory)
- **`fieldId`**: Identifies which field on that component
- **`key`**: A unique string combining both, used for identification
- **Equality**: Two endpoints are equal if both `componentId` and `fieldId` match

**Example Usage:**
```dart
const source = BusEndpoint(componentId: 'gpr', fieldId: 'readDataA');
const target = BusEndpoint(componentId: 'ula', fieldId: 'operandA');

print(source.key);  // Output: "gpr.readDataA"
print(source == target);  // Output: false
```

---

### BusConnection

**Location:** `lib/features/cpu_simulator/models/bus_connection.dart`

Represents an active connection between two endpoints.

```dart
class BusConnection {
  BusConnection({
    required this.source,     // Where data comes FROM
    required this.target,     // Where data goes TO
    required this.value,      // The value being transferred
    this.isAnimating = true,  // Is the animation currently running?
  }) : id = '${source.key}->${target.key}';

  final String id;           // Unique identifier
  final BusEndpoint source;
  final BusEndpoint target;
  final int value;
  final bool isAnimating;

  /// Immutable update pattern
  BusConnection copyWith({...}) { ... }
}
```

**Key Concepts:**
- **Immutability**: Uses `copyWith` pattern for updates (see [Common Patterns](#common-patterns-used))
- **`id`**: Auto-generated from source and target keys
- **`isAnimating`**: Controls whether the animation should play
- **`value`**: The actual data being transferred

**Example:**
```dart
final connection = BusConnection(
  source: BusEndpoint(componentId: 'gpr', fieldId: 'readDataA'),
  target: BusEndpoint(componentId: 'ula', fieldId: 'operandA'),
  value: 42,
  isAnimating: false,
);

print(connection.id);  // "gpr.readDataA->ula.operandA"

// To start animation (immutable update):
final animating = connection.copyWith(isAnimating: true);
```

---

### FieldPositionRegistry

**Location:** `lib/features/cpu_simulator/models/bus_connection.dart`

A static registry that stores the relative positions of all connectable fields.

```dart
class FieldPositionRegistry {
  FieldPositionRegistry._();  // Private constructor - cannot instantiate

  /// GPR field positions (relative to component, 0-1 range)
  static const Map<String, Offset> gprFields = {
    // Input fields (left side, x = 0.0)
    'readAddressA': Offset(0.0, 0.25),
    'readAddressB': Offset(0.0, 0.40),
    'writeAddress': Offset(0.0, 0.55),
    'writeData': Offset(0.0, 0.70),
    'writeEnable': Offset(0.0, 0.85),
    // Output fields (right side, x = 1.0)
    'readDataA': Offset(1.0, 0.35),
    'readDataB': Offset(1.0, 0.55),
  };

  /// ULA field positions
  static const Map<String, Offset> ulaFields = {
    'operandA': Offset(0.0, 0.35),
    'operandB': Offset(0.0, 0.65),
    'result': Offset(1.0, 0.5),
  };

  /// Source endpoints (outputs that can provide data)
  static const List<BusEndpoint> sourceEndpoints = [
    BusEndpoint(componentId: 'gpr', fieldId: 'readDataA'),
    BusEndpoint(componentId: 'gpr', fieldId: 'readDataB'),
    BusEndpoint(componentId: 'ula', fieldId: 'result'),
  ];

  /// Target endpoints (inputs that can receive data)
  static const List<BusEndpoint> targetEndpoints = [
    BusEndpoint(componentId: 'gpr', fieldId: 'readAddressA'),
    // ... more fields
    BusEndpoint(componentId: 'ula', fieldId: 'operandA'),
    BusEndpoint(componentId: 'ula', fieldId: 'operandB'),
  ];
}
```

**Understanding Relative Positions:**

The positions use a **normalized coordinate system** (0.0 to 1.0):

```
Component Widget
┌─────────────────────────────────────┐
│ (0,0)                         (1,0) │  ← Top edge
│                                     │
│ ● (0.0, 0.35) = Left side, 35% down │
│                                     │
│                    (1.0, 0.5) ●     │  ← Right side, 50% down
│                                     │
│ (0,1)                         (1,1) │  ← Bottom edge
└─────────────────────────────────────┘
```

- **X = 0.0**: Left edge of the component
- **X = 1.0**: Right edge of the component
- **Y = 0.0**: Top of the component
- **Y = 1.0**: Bottom of the component

**Why This Pattern?**
- **Responsive**: Works regardless of component size
- **Easy to Configure**: Just change the decimal values
- **Convention**: Inputs on left (0.0), outputs on right (1.0)

---

## State Management

**Location:** `lib/features/cpu_simulator/providers/cpu_simulator_state.dart`

The `CpuSimulatorState` class extends `ChangeNotifier` (Provider pattern) and manages:

### GlobalKeys for Component Positioning

```dart
class CpuSimulatorState extends ChangeNotifier {
  // Keys to access component RenderObjects for position calculation
  final GlobalKey gprKey = GlobalKey();
  final GlobalKey ulaKey = GlobalKey();
  final GlobalKey memoryKey = GlobalKey();

  /// Get the key for a component by ID
  GlobalKey? getComponentKey(String componentId) {
    return switch (componentId) {
      'gpr' => gprKey,
      'ula' => ulaKey,
      'memory' => memoryKey,
      _ => null,
    };
  }
}
```

**What are GlobalKeys?**
- A `GlobalKey` uniquely identifies a widget across the entire app
- It provides access to the widget's `RenderObject` (for size/position)
- Components receive these keys: `GprComponent(key: cpuState.gprKey, ...)`

### Bus Connection Management

```dart
final List<BusConnection> _busConnections = [];

List<BusConnection> get busConnections => List.unmodifiable(_busConnections);

/// Create a new connection (doesn't animate until clock)
void createBusConnection(BusEndpoint source, BusEndpoint target) {
  final sourceValue = getFieldValue(source);
  if (sourceValue == null) return;

  final connection = BusConnection(
    source: source,
    target: target,
    value: sourceValue,
    isAnimating: false,  // Wait for clock
  );

  _busConnections.add(connection);
  notifyListeners();
}

/// Remove a connection
void removeBusConnection(String connectionId) {
  _busConnections.removeWhere((c) => c.id == connectionId);
  notifyListeners();
}
```

### Field Value Access

The state provides methods to get/set values from any component field:

```dart
/// Get value from any endpoint
int? getFieldValue(BusEndpoint endpoint) {
  return switch (endpoint.componentId) {
    'gpr' => _getGprFieldValue(endpoint.fieldId),
    'ula' => _getUlaFieldValue(endpoint.fieldId),
    _ => null,
  };
}

int? _getGprFieldValue(String fieldId) {
  return switch (fieldId) {
    'readDataA' => _gprBank.readDataA,
    'readDataB' => _gprBank.readDataB,
    'readAddressA' => _gprBank.readAddressA,
    // ... more fields
    _ => null,
  };
}

/// Set value to any endpoint
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
```

---

## Widget System

### BusLayer

**Location:** `lib/features/cpu_simulator/widgets/bus/bus_layer.dart`

The `BusLayer` is an **overlay widget** that sits on top of all components and renders all bus connections.

```dart
class BusLayer extends StatefulWidget {
  const BusLayer({super.key});

  @override
  State<BusLayer> createState() => _BusLayerState();
}

class _BusLayerState extends State<BusLayer> {
  final GlobalKey _layerKey = GlobalKey();  // For coordinate conversion

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

              // Force rebuild after layout to get positions
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
}
```

**Key Concepts:**

1. **`Consumer<CpuSimulatorState>`**: Listens to state changes and rebuilds
2. **`Positioned.fill`**: Fills the entire Stack (same size as parent)
3. **`LayoutBuilder`**: Provides constraints, triggers after layout
4. **`addPostFrameCallback`**: Schedules rebuild after current frame (needed for position calculation)
5. **`ValueKey`**: Ensures each BusWidget has a stable identity

### BusWidget

**Location:** `lib/features/cpu_simulator/widgets/bus/bus_widget.dart`

The `BusWidget` draws a single bus connection with animation.

```dart
class BusWidget extends StatefulWidget {
  const BusWidget({
    super.key,
    required this.connection,
    required this.sourcePosition,   // Absolute position in parent
    required this.targetPosition,   // Absolute position in parent
    required this.numericSystem,
    this.color = Colors.blue,
    this.lineWidth = 3.0,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.onAnimationComplete,
  });
  // ...
}
```

**State Management with Animation:**

```dart
class _BusWidgetState extends State<BusWidget>
    with SingleTickerProviderStateMixin {  // Required for animations
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Create the animation controller
    _controller = AnimationController(
      vsync: this,  // Syncs with screen refresh
      duration: widget.animationDuration,
    );

    // Create the animation curve (0.0 → 1.0)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );

    // Listen for completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    // Start if animating
    if (widget.connection.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation when isAnimating changes to true
    if (widget.connection.isAnimating && !_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }
}
```

**Understanding `SingleTickerProviderStateMixin`:**
- Provides a `Ticker` (timing source) for the `AnimationController`
- Automatically pauses when widget is not visible
- Use `SingleTickerProviderStateMixin` for one animation, `TickerProviderStateMixin` for multiple

---

## Position Calculation Pipeline

This is one of the most complex parts of the system. Here's how positions are calculated:

### Step 1: Component Renders with GlobalKey

```dart
// In SimulatorPage
GprComponent(
  key: cpuState.gprKey,  // ← GlobalKey attached
  // ...
)
```

### Step 2: BusLayer Accesses Component RenderBox

```dart
Offset? _getLocalPosition(
  CpuSimulatorState cpuState,
  BusEndpoint endpoint,
  RenderBox layerBox,
) {
  // Get the component's GlobalKey
  final componentKey = cpuState.getComponentKey(endpoint.componentId);
  if (componentKey == null) return null;

  // Get the RenderBox (contains size and position info)
  final componentBox = componentKey.currentContext?.findRenderObject() as RenderBox?;
  if (componentBox == null) return null;

  // ... continue below
}
```

### Step 3: Get Relative Position from Registry

```dart
// Get the 0-1 relative position
final relativePosition = FieldPositionRegistry.getFieldPosition(endpoint);
if (relativePosition == null) return null;

// relativePosition might be Offset(1.0, 0.35) for gpr.readDataA
```

### Step 4: Convert to Component-Local Coordinates

```dart
// Get actual component size
final componentSize = componentBox.size;  // e.g., Size(200, 300)

// Convert 0-1 to actual pixels
final localInComponent = Offset(
  relativePosition.dx * componentSize.width,   // 1.0 * 200 = 200
  relativePosition.dy * componentSize.height,  // 0.35 * 300 = 105
);
// Result: Offset(200, 105) - 200px from left, 105px from top of component
```

### Step 5: Convert to Global, Then to Layer-Local

```dart
// Convert component-local to screen global
final globalPos = componentBox.localToGlobal(localInComponent);

// Convert screen global to BusLayer-local
return layerBox.globalToLocal(globalPos);
```

### Visual Representation

```
┌───────────────────── Screen ─────────────────────┐
│                                                   │
│  ┌───────────── SimulatorPage ───────────────┐   │
│  │                                            │   │
│  │  ┌──── BusLayer (layerBox) ──────────┐    │   │
│  │  │                                    │    │   │
│  │  │   ┌─ GPR (componentBox) ──┐       │    │   │
│  │  │   │                       │       │    │   │
│  │  │   │        ● ◄─ localInComponent  │    │   │
│  │  │   │                       │       │    │   │
│  │  │   └───────────────────────┘       │    │   │
│  │  │             ↓                      │    │   │
│  │  │      globalPos (screen coords)     │    │   │
│  │  │             ↓                      │    │   │
│  │  │      result (layer-local coords)   │    │   │
│  │  │                                    │    │   │
│  │  └────────────────────────────────────┘    │   │
│  └────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────┘
```

---

## Animation System

### Animation Flow

```
┌──────────────┐     Clock pressed     ┌───────────────────┐
│   Static     │ ────────────────────► │  isAnimating:true │
│   Bus Line   │                       │  Animation starts │
└──────────────┘                       └─────────┬─────────┘
                                                 │
                                                 ▼
┌──────────────┐     callback          ┌───────────────────┐
│   Static     │ ◄──────────────────── │  Animation runs   │
│   Bus Line   │  completeBusAnimation │  (packet moves)   │
│              │  isAnimating: false   │                   │
└──────────────┘                       └───────────────────┘
```

### AnimationController Lifecycle

```dart
// 1. Create controller in initState
_controller = AnimationController(
  vsync: this,
  duration: widget.animationDuration,
);

// 2. Create animation with curve
_animation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
);

// 3. Start animation
_controller.forward();      // Plays 0.0 → 1.0
_controller.forward(from: 0.0);  // Restart from beginning

// 4. Listen for completion
_controller.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    // Animation finished
  }
});

// 5. Dispose in dispose()
_controller.dispose();
```

### CustomPaint and the Painter

```dart
@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      return CustomPaint(
        painter: _BusPainter(
          progress: _animation.value,  // 0.0 to 1.0
          // ... other properties
        ),
      );
    },
  );
}
```

**How the Painter Draws:**

```dart
@override
void paint(Canvas canvas, Size size) {
  // 1. Draw the static line
  canvas.drawLine(sourcePosition, targetPosition, linePaint);

  // 2. Draw the animated packet (only while animating)
  if (progress > 0 && progress < 1) {
    // Interpolate position along the line
    final packetPosition = Offset.lerp(
      sourcePosition,
      targetPosition,
      progress,  // 0.0 = at source, 1.0 = at target
    )!;

    // Draw circle
    canvas.drawCircle(packetPosition, packetRadius, packetPaint);

    // Draw value text inside circle
    textPainter.paint(canvas, centeredPosition);
  }

  // 3. Draw endpoint indicators
  _drawEndpoint(canvas, sourcePosition, Colors.green);
  _drawEndpoint(canvas, targetPosition, Colors.red);
}
```

---

## Data Flow Pipeline

Here's the complete flow when data moves through a bus:

### 1. Connection Creation (User Action)

```dart
// User selects source and target in dialog, clicks "Create"
cpuState.createBusConnection(source, target);
```

```dart
void createBusConnection(BusEndpoint source, BusEndpoint target) {
  final sourceValue = getFieldValue(source);  // Read current value
  if (sourceValue == null) return;

  final connection = BusConnection(
    source: source,
    target: target,
    value: sourceValue,
    isAnimating: false,  // ← Not animating yet!
  );

  _busConnections.add(connection);
  notifyListeners();  // Triggers UI rebuild
}
```

### 2. Clock Triggered (User Presses Clock Button)

```dart
// In SimulatorPage
onPressed: cpuState.clockAll,
```

```dart
void clockAll() {
  // 1. First, transfer data through buses
  clockBus();

  // 2. Then clock components
  _gprBank = _gprBank.clock();
  _ulaState = _ulaState.clock();
  _programCounter++;

  notifyListeners();
}
```

### 3. Bus Clock - Transfer and Animate

```dart
void clockBus() {
  for (var i = 0; i < _busConnections.length; i++) {
    final conn = _busConnections[i];

    // Get fresh value from source
    final sourceValue = getFieldValue(conn.source);
    if (sourceValue == null) continue;

    // Update connection: new value + start animation
    _busConnections[i] = conn.copyWith(
      value: sourceValue,
      isAnimating: true,  // ← This triggers animation!
    );

    // Actually transfer the value
    setFieldValue(conn.target, sourceValue);
  }
  notifyListeners();
}
```

### 4. BusWidget Reacts to State Change

```dart
@override
void didUpdateWidget(BusWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // When isAnimating changes to true, start animation
  if (widget.connection.isAnimating && !_controller.isAnimating) {
    _controller.forward(from: 0.0);
  }
}
```

### 5. Animation Completes

```dart
_controller.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    widget.onAnimationComplete?.call();  // Calls back to BusLayer
  }
});
```

```dart
// In BusLayer
onAnimationComplete: () {
  cpuState.completeBusAnimation(connection.id);
},
```

```dart
void completeBusAnimation(String connectionId) {
  final index = _busConnections.indexWhere((c) => c.id == connectionId);
  if (index != -1) {
    _busConnections[index] = _busConnections[index].copyWith(
      isAnimating: false,  // Animation done
    );
    notifyListeners();
  }
}
```

---

## Clock System

The clock button triggers a synchronized update of all components:

```dart
void clockAll() {
  // Order matters! First transfer data, then clock components
  
  // 1. Transfer data through buses (and start animations)
  clockBus();

  // 2. Clock GPR (commits pending write if writeEnable)
  _gprBank = _gprBank.clock();

  // 3. Clock ULA (commits current calculation)
  _ulaState = _ulaState.clock();

  // 4. Increment program counter
  _programCounter++;

  notifyListeners();
}
```

**Why Order Matters:**
- Buses read source values first
- Then components are clocked
- This mimics real CPU timing where data must be stable before clock edge

---

## UI Dialog

**Location:** `lib/features/cpu_simulator/widgets/dialogs/bus_connection_dialog.dart`

The dialog allows users to:
1. Select a source endpoint (outputs only)
2. Select a target endpoint (inputs only)
3. See a preview of the connection
4. View and manage existing connections

```dart
class _BusConnectionDialogState extends State<BusConnectionDialog> {
  BusEndpoint? _sourceEndpoint;
  BusEndpoint? _targetEndpoint;

  @override
  Widget build(BuildContext context) {
    // Use dedicated lists (not getAllEndpoints)
    final sourceEndpoints = FieldPositionRegistry.sourceEndpoints;
    final targetEndpoints = FieldPositionRegistry.targetEndpoints.where((e) {
      // Filter out the selected source
      if (_sourceEndpoint != null && e == _sourceEndpoint) return false;
      return true;
    }).toList();

    // ... dropdown menus and UI
  }
}
```

---

## How to Add New Components

### Step 1: Add Field Positions

In `FieldPositionRegistry`:

```dart
/// New component field positions
static const Map<String, Offset> myNewComponentFields = {
  'input1': Offset(0.0, 0.3),
  'input2': Offset(0.0, 0.7),
  'output1': Offset(1.0, 0.5),
};
```

### Step 2: Add to Source/Target Lists

```dart
static const List<BusEndpoint> sourceEndpoints = [
  // ... existing
  BusEndpoint(componentId: 'myNewComponent', fieldId: 'output1'),
];

static const List<BusEndpoint> targetEndpoints = [
  // ... existing
  BusEndpoint(componentId: 'myNewComponent', fieldId: 'input1'),
  BusEndpoint(componentId: 'myNewComponent', fieldId: 'input2'),
];
```

### Step 3: Update getFieldsForComponent

```dart
static Map<String, Offset>? getFieldsForComponent(String componentId) {
  return switch (componentId) {
    'gpr' => gprFields,
    'ula' => ulaFields,
    'memory' => memoryFields,
    'myNewComponent' => myNewComponentFields,  // ← Add here
    _ => null,
  };
}
```

### Step 4: Add GlobalKey in CpuSimulatorState

```dart
final GlobalKey myNewComponentKey = GlobalKey();

GlobalKey? getComponentKey(String componentId) {
  return switch (componentId) {
    'gpr' => gprKey,
    'ula' => ulaKey,
    'memory' => memoryKey,
    'myNewComponent' => myNewComponentKey,  // ← Add here
    _ => null,
  };
}
```

### Step 5: Add Field Value Accessors

```dart
int? getFieldValue(BusEndpoint endpoint) {
  return switch (endpoint.componentId) {
    // ... existing
    'myNewComponent' => _getMyNewComponentFieldValue(endpoint.fieldId),
    _ => null,
  };
}

int? _getMyNewComponentFieldValue(String fieldId) {
  return switch (fieldId) {
    'output1' => _myNewComponentState.output1,
    _ => null,
  };
}
```

### Step 6: Use GlobalKey in Widget

```dart
MyNewComponent(
  key: cpuState.myNewComponentKey,  // ← Attach the key
  // ...
)
```

---

## Common Patterns Used

### 1. Immutable State with copyWith

Instead of mutating objects, create new instances:

```dart
class BusConnection {
  BusConnection copyWith({
    BusEndpoint? source,
    BusEndpoint? target,
    int? value,
    bool? isAnimating,
  }) {
    return BusConnection(
      source: source ?? this.source,     // Use new value or keep existing
      target: target ?? this.target,
      value: value ?? this.value,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

// Usage
final updated = connection.copyWith(isAnimating: true);
```

**Why?**
- Easier to track changes
- Works well with Flutter's rebuild system
- Prevents unexpected side effects

### 2. Provider Pattern (ChangeNotifier)

```dart
class CpuSimulatorState extends ChangeNotifier {
  int _value = 0;

  int get value => _value;

  void setValue(int newValue) {
    _value = newValue;
    notifyListeners();  // ← Triggers rebuild of Consumer widgets
  }
}

// In widget tree
Consumer<CpuSimulatorState>(
  builder: (context, state, child) {
    return Text('${state.value}');  // Rebuilds when notifyListeners called
  },
)
```

### 3. Switch Expressions (Dart 3.0+)

```dart
return switch (componentId) {
  'gpr' => gprFields,
  'ula' => ulaFields,
  'memory' => memoryFields,
  _ => null,  // Default case
};
```

### 4. Record Types for Multiple Returns

```dart
(Offset, Offset)? _calculatePositions(...) {
  // ...
  return (sourcePos, targetPos);  // Returns a tuple
}

// Usage
final positions = _calculatePositions(...);
if (positions != null) {
  final sourcePos = positions.$1;
  final targetPos = positions.$2;
}
```

### 5. GlobalKey for RenderObject Access

```dart
final GlobalKey myKey = GlobalKey();

// Attach to widget
MyWidget(key: myKey, ...)

// Later, access the RenderBox
final renderBox = myKey.currentContext?.findRenderObject() as RenderBox?;
if (renderBox != null) {
  final size = renderBox.size;
  final globalPos = renderBox.localToGlobal(Offset.zero);
}
```

---

## Troubleshooting

### Bus Lines Not Appearing

**Possible Causes:**
1. GlobalKey not attached to component
2. Component not yet rendered (positions null)
3. BusLayer not in Stack

**Solutions:**
- Verify `key: cpuState.gprKey` is on component
- Check if `addPostFrameCallback` is being called
- Ensure BusLayer is after components in Stack

### Positions Are Wrong

**Possible Causes:**
1. Relative positions incorrect in `FieldPositionRegistry`
2. Coordinate conversion issues

**Debug Steps:**
```dart
print('relativePosition: $relativePosition');
print('componentSize: ${componentBox.size}');
print('localInComponent: $localInComponent');
print('globalPos: $globalPos');
print('result: ${layerBox.globalToLocal(globalPos)}');
```

### Animation Not Playing

**Possible Causes:**
1. `isAnimating` never set to true
2. Controller not started
3. Widget not rebuilding

**Check:**
- Is `clockBus()` being called?
- Is `copyWith(isAnimating: true)` being applied?
- Is `didUpdateWidget` being triggered?

### Value Not Transferring

**Possible Causes:**
1. Source returns null
2. Target setter not implemented
3. Field ID mismatch

**Debug:**
```dart
print('Source: ${conn.source.key}');
print('Source value: ${getFieldValue(conn.source)}');
print('Target: ${conn.target.key}');
```

---

## Summary

The bus system is built on these key principles:

1. **Separation of Concerns**: Models, state, and widgets are separate
2. **Immutability**: State changes create new objects
3. **Reactive Updates**: Provider notifies widgets to rebuild
4. **Coordinate Transformation**: Global positions converted to local
5. **Clock-Driven**: Data transfers happen on clock, not immediately

This architecture makes the system:
- Easy to understand and debug
- Extensible for new components
- Visually accurate with proper positioning
- Educational with clear data flow visualization

---

*Last updated: January 2026*
