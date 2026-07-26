import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/sol_colors.dart';

enum SolFlowerState {
  resting,
  activity,
  tapped,
  celebrating,
}

class SolFlower extends StatefulWidget {
  const SolFlower({
    super.key,
    this.size = 104,
    this.fill = 1,
    this.state = SolFlowerState.resting,
    this.onTap,
    this.enableSway = true,
    this.petalCount = 16,
  });

  final double size;
  final double fill;
  final SolFlowerState state;
  final VoidCallback? onTap;
  final bool enableSway;
  final int petalCount;

  @override
  State<SolFlower> createState() => _SolFlowerState();
}

class _SolFlowerState extends State<SolFlower> with TickerProviderStateMixin {
  late final AnimationController _breatheController;
  late final AnimationController _swayFrontController;
  late final AnimationController _swayBackController;
  late final AnimationController _haloController;
  late final AnimationController _oneShotController;

  late Animation<double> _breatheScale;
  late Animation<double> _oneShotScale;

  bool _didConfigure = false;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(vsync: this);
    _swayFrontController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _swayBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    );
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _oneShotController = AnimationController(vsync: this);
    _breatheScale = const AlwaysStoppedAnimation<double>(1);
    _oneShotScale = const AlwaysStoppedAnimation<double>(1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didConfigure) {
      _didConfigure = true;
      _configureForState(widget.state);
    }
  }

  @override
  void didUpdateWidget(covariant SolFlower oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _configureForState(widget.state);
    }
  }

  void _configureForState(SolFlowerState state) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    _breatheController.stop();
    _swayFrontController.stop();
    _swayBackController.stop();
    _haloController.stop();

    if (reduceMotion) {
      _breatheScale = AlwaysStoppedAnimation<double>(1);
      _oneShotScale = AlwaysStoppedAnimation<double>(1);
      return;
    }

    switch (state) {
      case SolFlowerState.resting:
        _breatheController.duration = const Duration(milliseconds: 4500);
        _breatheScale = TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1, end: 1.04),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.04, end: 1),
            weight: 50,
          ),
        ]).animate(CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut));
        _breatheController.repeat();
        if (widget.enableSway) {
          _swayFrontController.repeat(reverse: true);
          _swayBackController.repeat(reverse: true);
        }
      case SolFlowerState.activity:
        _breatheController.duration = const Duration(milliseconds: 3200);
        _breatheScale = TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1, end: 1.06),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.06, end: 1),
            weight: 50,
          ),
        ]).animate(CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut));
        _breatheController.repeat();
        _haloController.repeat(reverse: true);
        if (widget.enableSway) {
          _swayFrontController.repeat(reverse: true);
          _swayBackController.repeat(reverse: true);
        }
      case SolFlowerState.tapped:
        _oneShotController.duration = const Duration(milliseconds: 520);
        _oneShotScale = TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1, end: 1.12)
                .chain(CurveTween(curve: const Cubic(0.34, 1.25, 0.5, 1))),
            weight: 45,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.12, end: 1)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 55,
          ),
        ]).animate(_oneShotController);
        _oneShotController.forward(from: 0);
      case SolFlowerState.celebrating:
        _oneShotController.duration = const Duration(milliseconds: 1500);
        _oneShotScale = TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1, end: 1.08),
            weight: 40,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.08, end: 1),
            weight: 60,
          ),
        ]).animate(CurvedAnimation(parent: _oneShotController, curve: Curves.easeOut));
        _oneShotController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _swayFrontController.dispose();
    _swayBackController.dispose();
    _haloController.dispose();
    _oneShotController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool showHalo = widget.state == SolFlowerState.activity;
    return GestureDetector(
      onTap: widget.onTap == null ? null : _handleTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            _breatheController,
            _swayFrontController,
            _swayBackController,
            _haloController,
            _oneShotController,
          ]),
          builder: (BuildContext context, Widget? child) {
            final double breathe =
                (_breatheController.isAnimating) ? _breatheScale.value : 1;
            final double oneShot =
                (_oneShotController.isAnimating ||
                        widget.state == SolFlowerState.tapped ||
                        widget.state == SolFlowerState.celebrating)
                    ? (_oneShotScale.value)
                    : 1;
            final double scale = breathe * oneShot;
            final double frontSway =
                (_swayFrontController.isAnimating ? (_swayFrontController.value * 2 - 1) : 0) *
                    1.5 *
                    (math.pi / 180);
            final double backSway =
                (_swayBackController.isAnimating ? (_swayBackController.value * 2 - 1) : 0) *
                    -1.5 *
                    (math.pi / 180);
            final double haloOpacity =
                showHalo ? (0.5 + _haloController.value * 0.5) : 0;
            final double haloScale =
                showHalo ? (0.96 + _haloController.value * 0.08) : 1;

            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                if (showHalo)
                  Transform.scale(
                    scale: haloScale,
                    child: Opacity(
                      opacity: haloOpacity,
                      child: Container(
                        width: widget.size * 1.28,
                        height: widget.size * 1.28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              SolColors.gold.withValues(alpha: 0.33),
                              SolColors.coral.withValues(alpha: 0.13),
                              Colors.transparent,
                            ],
                            stops: const <double>[0, 0.45, 0.7],
                          ),
                        ),
                      ),
                    ),
                  ),
                Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    size: Size.square(widget.size),
                    painter: _SolFlowerPainter(
                      fill: widget.fill.clamp(0, 1),
                      petalCount: widget.petalCount,
                      frontSwayRadians: frontSway,
                      backSwayRadians: backSway,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SolFlowerPainter extends CustomPainter {
  const _SolFlowerPainter({
    required this.fill,
    required this.petalCount,
    required this.frontSwayRadians,
    required this.backSwayRadians,
  });

  final double fill;
  final int petalCount;
  final double frontSwayRadians;
  final double backSwayRadians;

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    canvas.translate(center, center);
    final double unit = size.width / 120;
    final int filledCount = (petalCount * fill).round();

    final Paint petalPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          SolColors.petalStart,
          SolColors.petalMid,
          SolColors.petalEnd,
        ],
        stops: <double>[0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 50 * unit));

    canvas.save();
    canvas.rotate(backSwayRadians);
    for (int i = 0; i < petalCount; i++) {
      canvas.save();
      canvas.rotate((i * 2 * math.pi / petalCount) + (11.25 * math.pi / 180));
      petalPaint.color = Colors.white.withValues(alpha: i < filledCount ? 0.5 : 0.12);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -38 * unit), width: 16 * unit, height: 42 * unit),
        petalPaint..color = SolColors.petalMid.withValues(alpha: i < filledCount ? 0.5 : 0.12),
      );
      canvas.restore();
    }
    canvas.restore();

    canvas.save();
    canvas.rotate(frontSwayRadians);
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6 * unit;
    for (int i = 0; i < petalCount; i++) {
      canvas.save();
      canvas.rotate(i * 2 * math.pi / petalCount);
      final Rect petalRect = Rect.fromCenter(
        center: Offset(0, -38 * unit),
        width: 17 * unit,
        height: 44 * unit,
      );
      if (i < filledCount) {
        canvas.drawOval(petalRect, petalPaint..color = SolColors.petalMid.withValues(alpha: 0.96));
        strokePaint.color = Colors.white.withValues(alpha: 0.4);
        canvas.drawOval(petalRect, strokePaint);
      } else {
        strokePaint.color = SolColors.cocoa.withValues(alpha: 0.16);
        canvas.drawOval(petalRect, strokePaint);
      }
      canvas.restore();
    }
    canvas.restore();

    final Paint seedPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.1),
        radius: 0.58,
        colors: <Color>[
          SolColors.seedStart,
          SolColors.seedMid,
          SolColors.seedEnd,
        ],
        stops: <double>[0, 0.65, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 21 * unit));
    canvas.drawCircle(Offset.zero, 21 * unit, seedPaint);

    final Paint seedDotPaint = Paint();
    for (int i = 0; i < 130; i++) {
      final double angle = i * 137.5 * (math.pi / 180);
      final double radius = 1.55 * math.sqrt(i) * unit;
      if (radius > 19 * unit) {
        continue;
      }
      final double t = radius / (19 * unit);
      seedDotPaint.color = (t < 0.5 ? SolColors.seedDotLight : SolColors.seedDotDark)
          .withValues(alpha: fill < 0.15 ? 0.25 : 0.55);
      canvas.drawCircle(
        Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        (1.2 - t * 0.4) * unit,
        seedDotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SolFlowerPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.petalCount != petalCount ||
        oldDelegate.frontSwayRadians != frontSwayRadians ||
        oldDelegate.backSwayRadians != backSwayRadians;
  }
}

class SolProgressFlower extends StatelessWidget {
  const SolProgressFlower({
    super.key,
    required this.fill,
    this.size = 46,
  });

  final double fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ProgressFlowerPainter(fill: fill.clamp(0, 1)),
    );
  }
}

class _ProgressFlowerPainter extends CustomPainter {
  const _ProgressFlowerPainter({required this.fill});

  final double fill;

  @override
  void paint(Canvas canvas, Size size) {
    const int petalCount = 14;
    final int filledCount = (petalCount * fill).round();
    final double unit = size.width / 120;
    canvas.translate(size.width / 2, size.height / 2);

    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[SolColors.gold, SolColors.coral, SolColors.rose],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 50 * unit));
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * unit
      ..color = SolColors.cocoa.withValues(alpha: 0.18);

    for (int i = 0; i < petalCount; i++) {
      canvas.save();
      canvas.rotate(i * 2 * math.pi / petalCount);
      final Rect petal = Rect.fromCenter(
        center: Offset(0, -36 * unit),
        width: 17 * unit,
        height: 38 * unit,
      );
      if (i < filledCount) {
        canvas.drawOval(petal, fillPaint);
      } else {
        canvas.drawOval(petal, strokePaint);
      }
      canvas.restore();
    }

    canvas.drawCircle(
      Offset.zero,
      16 * unit,
      Paint()
        ..color = SolColors.cream
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset.zero,
      16 * unit,
      Paint()
        ..color = SolColors.cocoa.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * unit,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressFlowerPainter oldDelegate) {
    return oldDelegate.fill != fill;
  }
}
