/// Model representing the ULA (Arithmetic Logic Unit) state.
class UlaState {
  // ══════════════════════════════════════════════════════════════
  // Fields
  // ══════════════════════════════════════════════════════════════
  final int operandA;
  final int operandB;
  final int result;
  final UlaOperation operation;
  final UlaFlags flags;

  // ══════════════════════════════════════════════════════════════
  // Constructor
  // ══════════════════════════════════════════════════════════════
  const UlaState({
    this.operandA = 0,
    this.operandB = 0,
    this.result = 0,
    this.operation = UlaOperation.none,
    this.flags = const UlaFlags(),
  });

  // ══════════════════════════════════════════════════════════════
  // Methods
  // ══════════════════════════════════════════════════════════════

  UlaState withOperandA(int a) {
    return copyWith(operandA: a);
  }

  UlaState withOperandB(int b) {
    return copyWith(operandB: b);
  }

  UlaState withOperands(int a, int b) {
    return copyWith(operandA: a, operandB: b);
  }

  UlaState withOperation(UlaOperation op) {
    return copyWith(operation: op);
  }

  /// Execute an operation and return a new UlaState with the result
  UlaState clock() {
    final result = switch (operation) {
      UlaOperation.add => operandA + operandB,
      UlaOperation.sub => operandA - operandB,
      UlaOperation.and_ => operandA & operandB,
      UlaOperation.or_ => operandA | operandB,
      UlaOperation.xor => operandA ^ operandB,
      UlaOperation.not => ~operandA,
      UlaOperation.shl => operandA << operandB,
      UlaOperation.shr => operandA >> operandB,
      UlaOperation.none => 0,
    };

    return copyWith(
      operation: operation,
      result: result,
      flags: UlaFlags(
        zero: result == 0,
        negative: result < 0,
        // TODO: carry and overflow need more complex logic
      ),
    );
  }

  UlaState copyWith({
    int? operandA,
    int? operandB,
    int? result,
    UlaOperation? operation,
    UlaFlags? flags,
  }) {
    return UlaState(
      operandA: operandA ?? this.operandA,
      operandB: operandB ?? this.operandB,
      result: result ?? this.result,
      operation: operation ?? this.operation,
      flags: flags ?? this.flags,
    );
  }
}

enum UlaOperation { none, add, sub, and_, or_, xor, not, shl, shr }

class UlaFlags {
  // ══════════════════════════════════════════════════════════════
  // Fields
  // ══════════════════════════════════════════════════════════════
  final bool zero;
  final bool carry;
  final bool negative;
  final bool overflow;

  // ══════════════════════════════════════════════════════════════
  // Constructor
  // ══════════════════════════════════════════════════════════════
  const UlaFlags({
    this.zero = false,
    this.carry = false,
    this.negative = false,
    this.overflow = false,
  });

  // ══════════════════════════════════════════════════════════════
  // Methods
  // ══════════════════════════════════════════════════════════════
  UlaFlags copyWith({bool? zero, bool? carry, bool? negative, bool? overflow}) {
    return UlaFlags(
      zero: zero ?? this.zero,
      carry: carry ?? this.carry,
      negative: negative ?? this.negative,
      overflow: overflow ?? this.overflow,
    );
  }
}
