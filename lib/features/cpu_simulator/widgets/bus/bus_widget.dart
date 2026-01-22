import 'package:flutter/material.dart';

import '../../models/bus_connection.dart';
import '../../utils/number_formatter.dart';

/// Widget that paints a bus connection between two component fields.
///
/// The bus displays as a line connecting the source and target positions,
/// with an animated "data packet" flowing from source to target.
class BusWidget extends StatefulWidget {
  const BusWidget({
    super.key,
    required this.connection,
    required this.sourcePosition,
    required this.targetPosition,
    required this.numericSystem,
    this.color = Colors.blue,
    this.lineWidth = 3.0,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.onAnimationComplete,
  });

  /// The bus connection data
  final BusConnection connection;

  /// Absolute position of the source field in the widget tree
  final Offset sourcePosition;

  /// Absolute position of the target field in the widget tree
  final Offset targetPosition;

  /// The numeric system for displaying values
  final NumericSystem numericSystem;

  /// Color of the bus line
  final Color color;

  /// Width of the bus line
  final double lineWidth;

  /// Duration of the data flow animation
  final Duration animationDuration;

  /// Callback when animation completes
  final VoidCallback? onAnimationComplete;

  @override
  State<BusWidget> createState() => _BusWidgetState();
}

class _BusWidgetState extends State<BusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    if (widget.connection.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connection.isAnimating && !_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _BusPainter(
            sourcePosition: widget.sourcePosition,
            targetPosition: widget.targetPosition,
            progress: _animation.value,
            color: widget.color,
            lineWidth: widget.lineWidth,
            value: widget.connection.value,
            numericSystem: widget.numericSystem,
          ),
        );
      },
    );
  }
}

class _BusPainter extends CustomPainter {
  _BusPainter({
    required this.sourcePosition,
    required this.targetPosition,
    required this.progress,
    required this.color,
    required this.lineWidth,
    required this.value,
    required this.numericSystem,
  });

  final Offset sourcePosition;
  final Offset targetPosition;
  final double progress;
  final Color color;
  final double lineWidth;
  final int value;
  final NumericSystem numericSystem;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the bus line
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(sourcePosition, targetPosition, linePaint);

    // Draw the animated data packet
    if (progress > 0 && progress < 1) {
      final packetPosition = Offset.lerp(
        sourcePosition,
        targetPosition,
        progress,
      )!;

      // Draw packet background
      final packetPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      const packetRadius = 12.0;
      canvas.drawCircle(packetPosition, packetRadius, packetPaint);

      // Draw value text
      final textPainter = TextPainter(
        text: TextSpan(
          text: NumberFormatter.format(
            value,
            system: numericSystem,
            showPrefix: false,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        packetPosition - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Draw source indicator
    _drawEndpoint(canvas, sourcePosition, Colors.green);

    // Draw target indicator
    _drawEndpoint(canvas, targetPosition, Colors.red);
  }

  void _drawEndpoint(Canvas canvas, Offset position, Color indicatorColor) {
    final paint = Paint()
      ..color = indicatorColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, 6, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, 6, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BusPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.sourcePosition != sourcePosition ||
        oldDelegate.targetPosition != targetPosition;
  }
}
