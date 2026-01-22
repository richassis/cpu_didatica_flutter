/// Represents a single CPU register.
class Register {
  // ══════════════════════════════════════════════════════════════
  // Fields
  // ══════════════════════════════════════════════════════════════
  final int? address;
  final String name;
  final int value;
  final int bitWidth;

  // ══════════════════════════════════════════════════════════════
  // Constructor
  // ══════════════════════════════════════════════════════════════
  const Register({
    this.address,
    required this.name,
    required this.value,
    this.bitWidth = 16,
  });

  // ══════════════════════════════════════════════════════════════
  // Getters
  // ══════════════════════════════════════════════════════════════

  String get hexAddress {
    if (address == null) {
      return 'N/A';
    }
    final hexDigits = (bitWidth / 4).ceil();
    return '0x${address?.toRadixString(16).padLeft(hexDigits, '0').toUpperCase()}';
  }

  /// Returns the value as a hex string (e.g., "0x00FF")
  String get hexValue {
    final hexDigits = (bitWidth / 4).ceil();
    return '0x${value.toRadixString(16).padLeft(hexDigits, '0').toUpperCase()}';
  }

  String get decimalValue {
    return value.toString();
  }

  /// Returns the value as a binary string
  String get binaryValue {
    return value.toRadixString(2).padLeft(bitWidth, '0');
  }

  String getAnyValue(String numericSystem) {
    switch (numericSystem) {
      case 'hex':
        return hexValue;
      case 'dec':
        return decimalValue;
      case 'bin':
        return binaryValue;
      default:
        return hexValue;
    }
  }

  Register updateValue(int newValue) {
    return Register(
      address: address,
      name: name,
      value: newValue,
      bitWidth: bitWidth,
    );
  }

  Register copyWith({String? name, int? value, int? bitWidth}) {
    return Register(
      address: address,
      name: name ?? this.name,
      value: value ?? this.value,
      bitWidth: bitWidth ?? this.bitWidth,
    );
  }
}
