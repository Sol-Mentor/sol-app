import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/sol_colors.dart';

class SolMark extends StatelessWidget {
  const SolMark({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SolMarkPainter(),
    );
  }
}

class SolMarkRotating extends StatefulWidget {
  const SolMarkRotating({
    super.key,
    this.size = 30,
    this.rotationDuration = const Duration(seconds: 28),
  });

  final double size;
  final Duration rotationDuration;

  @override
  State<SolMarkRotating> createState() => _SolMarkRotatingState();
}

class _SolMarkRotatingState extends State<SolMarkRotating>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationController,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _SolMarkPainter(),
      ),
    );
  }
}

class _SolMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 40;
    canvas.translate(size.width / 2, size.height / 2);
    final Paint petalPaint = Paint()..color = SolColors.coral;
    for (int i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 4);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -9.5 * unit), width: 10 * unit, height: 17 * unit),
        petalPaint,
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 6.2 * unit, Paint()..color = SolColors.gold);
    canvas.drawCircle(
      Offset.zero,
      6.2 * unit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * unit
        ..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
