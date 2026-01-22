/// Enum representing the numeric system for display.
enum NumericSystem { hex, dec, bin }

/// Utility class for formatting numbers in different numeric systems.
class NumberFormatter {
  NumberFormatter._();

  /// Format an integer value according to the numeric system.
  ///
  /// [value] - The integer value to format
  /// [system] - The numeric system to use (hex, dec, bin)
  /// [padWidth] - Optional padding width (defaults based on system)
  /// [showPrefix] - Whether to show prefix (0x, 0b) for hex/bin
  static String format(
    int value, {
    required NumericSystem system,
    int? padWidth,
    bool showPrefix = true,
  }) {
    return switch (system) {
      NumericSystem.hex => _formatHex(
        value,
        padWidth: padWidth,
        showPrefix: showPrefix,
      ),
      NumericSystem.dec => value.toString(),
      NumericSystem.bin => _formatBin(
        value,
        padWidth: padWidth,
        showPrefix: showPrefix,
      ),
    };
  }

  /// Format as hexadecimal.
  static String _formatHex(int value, {int? padWidth, bool showPrefix = true}) {
    final hex = value.toRadixString(16).toUpperCase();
    final padded = padWidth != null ? hex.padLeft(padWidth, '0') : hex;
    return showPrefix ? '0x$padded' : padded;
  }

  /// Format as binary.
  static String _formatBin(int value, {int? padWidth, bool showPrefix = true}) {
    final bin = value.toRadixString(2);
    final padded = padWidth != null ? bin.padLeft(padWidth, '0') : bin;
    return showPrefix ? '0b$padded' : padded;
  }

  /// Format a nullable integer, returning a placeholder if null.
  static String formatNullable(
    int? value, {
    required NumericSystem system,
    int? padWidth,
    bool showPrefix = true,
    String placeholder = '—',
  }) {
    if (value == null) return placeholder;
    return format(
      value,
      system: system,
      padWidth: padWidth,
      showPrefix: showPrefix,
    );
  }

  /// Parse a string to integer, supporting hex (0x), binary (0b), and decimal.
  ///
  /// If [context] is provided, values without prefixes are parsed according to that system.
  /// Otherwise, only prefixed values (0x, 0b) and decimal are supported.
  ///
  /// Returns null if parsing fails.
  static int? parse(String text, {NumericSystem? context}) {
    final trimmed = text.trim().toLowerCase();

    if (trimmed.isEmpty) return null;

    // Try hex format (0x prefix)
    if (trimmed.startsWith('0x')) {
      return int.tryParse(trimmed.substring(2), radix: 16);
    }

    // Try binary format (0b prefix)
    if (trimmed.startsWith('0b')) {
      return int.tryParse(trimmed.substring(2), radix: 2);
    }

    // If context is provided, parse according to that system
    if (context != null) {
      return switch (context) {
        NumericSystem.hex => int.tryParse(trimmed, radix: 16),
        NumericSystem.bin => int.tryParse(trimmed, radix: 2),
        NumericSystem.dec => int.tryParse(trimmed),
      };
    }

    // Default: try decimal
    return int.tryParse(trimmed);
  }

  /// Get the label for a numeric system.
  static String label(NumericSystem system) {
    return switch (system) {
      NumericSystem.hex => 'Hex',
      NumericSystem.dec => 'Dec',
      NumericSystem.bin => 'Bin',
    };
  }
}
