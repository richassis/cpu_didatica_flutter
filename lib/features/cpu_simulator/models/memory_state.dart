/// Model representing the Memory state.
class MemoryState {
  // ══════════════════════════════════════════════════════════════
  // Fields
  // ══════════════════════════════════════════════════════════════
  final int size;
  final int wordSize;
  final Map<int, int> _data;

  // ══════════════════════════════════════════════════════════════
  // Constructor
  // ══════════════════════════════════════════════════════════════
  MemoryState({this.size = 256, this.wordSize = 16, Map<int, int>? initialData})
    : _data = initialData ?? {};

  // ══════════════════════════════════════════════════════════════
  // Methods
  // ══════════════════════════════════════════════════════════════

  /// Read a value from memory
  int read(int address) {
    if (address < 0 || address >= size) {
      throw RangeError('Memory address $address out of bounds (0-${size - 1})');
    }
    return _data[address] ?? 0;
  }

  /// Create a copy with an updated memory value
  MemoryState write(int address, int value) {
    if (address < 0 || address >= size) {
      throw RangeError('Memory address $address out of bounds (0-${size - 1})');
    }
    final newData = Map<int, int>.from(_data);
    newData[address] = value;
    return MemoryState(size: size, wordSize: wordSize, initialData: newData);
  }

  /// Get all non-zero memory addresses for display
  List<MapEntry<int, int>> get nonZeroEntries {
    return _data.entries.where((e) => e.value != 0).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  /// Get the start address (always 0)
  int get startAddress => 0;

  /// Get the end address
  int get endAddress => size - 1;
}
