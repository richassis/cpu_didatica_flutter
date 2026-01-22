import 'register.dart';

/// Immutable model representing the General Purpose Register bank.
class GprBank {
  // ══════════════════════════════════════════════════════════════
  // Fields
  // ══════════════════════════════════════════════════════════════
  final int registerCount;
  final int bitWidth;
  final List<Register> registers;

  final int? readAddressA;
  final int? readAddressB;
  final int? readDataA;
  final int? readDataB;
  final int? writeAddress;
  final int? writeData;
  final bool? writeEnable;

  // ══════════════════════════════════════════════════════════════
  // Constructor
  // ══════════════════════════════════════════════════════════════
  GprBank({
    this.registerCount = 8,
    this.bitWidth = 16,
    List<int>? initialValues,
    List<Register>? registers,
    this.readAddressA,
    this.readAddressB,
    this.readDataA,
    this.readDataB,
    this.writeAddress,
    this.writeData,
    this.writeEnable,
  }) : registers = List<Register>.unmodifiable(
         registers ??
             List.generate(
               registerCount,
               (index) => Register(
                 address: index,
                 name: 'R$index',
                 value: initialValues != null && index < initialValues.length
                     ? initialValues[index]
                     : 0,
                 bitWidth: bitWidth,
               ),
             ),
       );

  // ══════════════════════════════════════════════════════════════
  // Helpers / copyWith
  // ══════════════════════════════════════════════════════════════

  GprBank copyWith({
    int? registerCount,
    int? bitWidth,
    List<Register>? registers,
    int? readAddressA,
    int? readAddressB,
    int? readDataA,
    int? readDataB,
    int? writeAddress,
    int? writeData,
    bool? writeEnable,
  }) {
    return GprBank(
      registerCount: registerCount ?? this.registerCount,
      bitWidth: bitWidth ?? this.bitWidth,
      registers: registers ?? this.registers,
      readAddressA: readAddressA ?? this.readAddressA,
      readAddressB: readAddressB ?? this.readAddressB,
      readDataA: readDataA ?? this.readDataA,
      readDataB: readDataB ?? this.readDataB,
      writeAddress: writeAddress ?? this.writeAddress,
      writeData: writeData ?? this.writeData,
      writeEnable: writeEnable ?? this.writeEnable,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Methods (immutable - return new instances)
  // ══════════════════════════════════════════════════════════════

  /// Set read data A explicitly.
  GprBank withReadDataA(int? data) => copyWith(readDataA: data);

  /// Set read data B explicitly.
  GprBank withReadDataB(int? data) => copyWith(readDataB: data);

  /// Set read address A and update readDataA accordingly.
  GprBank withReadAddressA(int? address) {
    final data = (address != null && address >= 0 && address < registers.length)
        ? registers[address].value
        : null;
    return copyWith(readAddressA: address, readDataA: data);
  }

  /// Set read address B and update readDataB accordingly.
  GprBank withReadAddressB(int? address) {
    final data = (address != null && address >= 0 && address < registers.length)
        ? registers[address].value
        : null;
    return copyWith(readAddressB: address, readDataB: data);
  }

  GprBank withWriteAddress(int? address) => copyWith(writeAddress: address);
  GprBank withWriteData(int? data) => copyWith(writeData: data);
  GprBank withWriteEnable(bool? enable) => copyWith(writeEnable: enable);

  /// Emulate a clock edge: if writeEnable and writeAddress/data valid,
  /// return a new GprBank with the register updated.
  GprBank clock() {
    if (writeEnable == true && writeAddress != null && writeData != null) {
      final address = writeAddress!;
      final data = writeData!;
      if (address >= 0 && address < registers.length) {
        final newRegs = registers.toList();
        newRegs[address] = newRegs[address].updateValue(data);
        return copyWith(registers: List<Register>.unmodifiable(newRegs));
      }
    }
    return this; // no change
  }

  /// Return a new GprBank with all registers reset to zero.
  GprBank reset() {
    final newRegs = List.generate(
      registerCount,
      (i) => Register(address: i, name: 'R$i', value: 0, bitWidth: bitWidth),
    );
    return copyWith(registers: List<Register>.unmodifiable(newRegs));
  }

  /// Get a register by address
  Register operator [](int address) => registers[address];

  /// Create a copy with an updated register value at `address`.
  GprBank updateRegister(int address, int value) {
    final newValues = registers.map((r) => r.value).toList();
    newValues[address] = value;
    return GprBank(
      registerCount: registerCount,
      bitWidth: bitWidth,
      initialValues: newValues,
      readAddressA: readAddressA,
      readAddressB: readAddressB,
      readDataA: readDataA,
      readDataB: readDataB,
      writeAddress: writeAddress,
      writeData: writeData,
      writeEnable: writeEnable,
    );
  }
}
