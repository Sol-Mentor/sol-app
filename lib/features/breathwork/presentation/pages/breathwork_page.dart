import 'package:flutter/material.dart';

import '../../../../core/theme/sol_colors.dart';
import '../../../../shared/widgets/sol_flower.dart';
import '../../../../shared/widgets/sol_ui.dart';

enum _BreathPhase { ready, inhale, exhale, paused, complete }

class BreathworkPage extends StatefulWidget {
  const BreathworkPage({super.key});

  @override
  State<BreathworkPage> createState() => _BreathworkPageState();
}

class _BreathworkPageState extends State<BreathworkPage>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 5 * 60;
  static const int _inhaleSeconds = 4;
  static const int _exhaleSeconds = 6;

  late final AnimationController _flowerController;
  _BreathPhase _phase = _BreathPhase.ready;
  int _secondsLeft = _totalSeconds;
  int _phaseCountdown = _inhaleSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _flowerController = AnimationController(
      vsync: this,
      lowerBound: 0.7,
      upperBound: 1,
      value: 0.7,
    );
  }

  @override
  void dispose() {
    _flowerController.dispose();
    super.dispose();
  }

  String get _timerLabel {
    final int minutes = _secondsLeft ~/ 60;
    final int seconds = _secondsLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get _phaseLabel {
    switch (_phase) {
      case _BreathPhase.ready:
        return 'Ready';
      case _BreathPhase.inhale:
        return 'Breathe in';
      case _BreathPhase.exhale:
        return 'Breathe out';
      case _BreathPhase.paused:
        return 'Paused';
      case _BreathPhase.complete:
        return 'Done';
    }
  }

  Future<void> _begin() async {
    setState(() {
      _isRunning = true;
      _phase = _BreathPhase.inhale;
      _secondsLeft = _totalSeconds;
      _phaseCountdown = _inhaleSeconds;
    });
    await _runSession();
  }

  Future<void> _runSession() async {
    while (mounted && _isRunning && _secondsLeft > 0) {
      if (_phase == _BreathPhase.paused) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        continue;
      }
      if (_phase == _BreathPhase.inhale) {
        _flowerController.duration = const Duration(seconds: _inhaleSeconds);
        _flowerController.forward(from: 0.7);
        for (int i = _inhaleSeconds; i >= 1; i--) {
          if (!_isRunning || _phase == _BreathPhase.paused) break;
          setState(() {
            _phaseCountdown = i;
            _secondsLeft -= 1;
          });
          await Future<void>.delayed(const Duration(seconds: 1));
          if (_secondsLeft <= 0) break;
        }
        if (_isRunning && _phase != _BreathPhase.paused && _secondsLeft > 0) {
          setState(() => _phase = _BreathPhase.exhale);
        }
      } else if (_phase == _BreathPhase.exhale) {
        _flowerController.duration = const Duration(seconds: _exhaleSeconds);
        _flowerController.reverse(from: 1);
        for (int i = _exhaleSeconds; i >= 1; i--) {
          if (!_isRunning || _phase == _BreathPhase.paused) break;
          setState(() {
            _phaseCountdown = i;
            _secondsLeft -= 1;
          });
          await Future<void>.delayed(const Duration(seconds: 1));
          if (_secondsLeft <= 0) break;
        }
        if (_isRunning && _phase != _BreathPhase.paused && _secondsLeft > 0) {
          setState(() => _phase = _BreathPhase.inhale);
        }
      }
    }
    if (mounted && _secondsLeft <= 0) {
      setState(() {
        _isRunning = false;
        _phase = _BreathPhase.complete;
      });
    }
  }

  void _pause() {
    setState(() {
      _phase = _BreathPhase.paused;
      _isRunning = false;
    });
    _flowerController.stop();
  }

  void _resume() {
    setState(() {
      _isRunning = true;
      _phase = _flowerController.value > 0.85 ? _BreathPhase.exhale : _BreathPhase.inhale;
    });
    _runSession();
  }

  void _reset() {
    setState(() {
      _isRunning = false;
      _phase = _BreathPhase.ready;
      _secondsLeft = _totalSeconds;
      _phaseCountdown = _inhaleSeconds;
    });
    _flowerController.value = 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return SolPageScaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.64),
            radius: 1.3,
            colors: <Color>[Colors.white, SolColors.dawn, Color(0xFFEFE4D6)],
            stops: <double>[0, 0.55, 1],
          ),
        ),
        child: Column(
          children: <Widget>[
              Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Close'),
                  ),
                  const Expanded(
                    child: Text(
                      'Breathe',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                  ),
                  const SizedBox(width: 64),
                ],
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          SolColors.gold.withValues(alpha: 0.15),
                          SolColors.coral.withValues(alpha: 0.07),
                          Colors.transparent,
                        ],
                        stops: const <double>[0, 0.45, 0.72],
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: _flowerController,
                    child: const SolFlower(
                      size: 210,
                      fill: 1,
                      state: SolFlowerState.resting,
                      enableSway: false,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _phaseLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          shadows: <Shadow>[
                            Shadow(color: Color(0x803A2D26), blurRadius: 3),
                          ],
                        ),
                      ),
                      if (_phase == _BreathPhase.inhale || _phase == _BreathPhase.exhale)
                        Text(
                          '$_phaseCountdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            shadows: <Shadow>[
                              Shadow(color: Color(0x803A2D26), blurRadius: 3),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _timerLabel,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: SolPrimaryButton(
                  label: _phase == _BreathPhase.ready
                      ? 'Begin'
                      : _phase == _BreathPhase.paused
                          ? 'Resume'
                          : _phase == _BreathPhase.complete
                              ? 'Mark as done'
                              : 'Pause',
                  onPressed: () {
                    if (_phase == _BreathPhase.ready) {
                      _begin();
                    } else if (_phase == _BreathPhase.paused) {
                      _resume();
                    } else if (_phase == _BreathPhase.complete) {
                      showSolToast(
                        context,
                        title: 'Marked done',
                        subtitle: '5 minute breathwork',
                      );
                      Navigator.of(context).maybePop();
                    } else {
                      _pause();
                    }
                  },
                ),
              ),
              if (_phase != _BreathPhase.ready && _phase != _BreathPhase.complete)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextButton(onPressed: _reset, child: const Text('Reset')),
                ),
            ],
          ),
        ),
    );
  }
}
