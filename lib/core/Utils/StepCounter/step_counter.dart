import 'dart:async';
import 'dart:io';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'step_record.dart';
import 'step_repository.dart';

class StepCounter {
  final StepRepository repository;
  final bool _ownsRepository;

  final StreamController<int> _stepCountController =
      StreamController<int>.broadcast();

  final StreamController<StepRecord> _stepController =
      StreamController<StepRecord>.broadcast();

  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();

  StreamSubscription<StepCount>? _stepCountSubscription;

  int _currentSteps = 0;
  int? _lastRawStepCount;
  DateTime? _lastSensorTimestamp;
  DateTime? _lastStepTimestamp;

  String? _currentDateKey;

  bool _isRunning = false;
  bool _isDisposed = false;

  Future<void> _processing = Future<void>.value();

  StepCounter({
    StepRepository? repository,
  })  : repository = repository ?? StepRepository(),
        _ownsRepository = repository == null;

  /// Number of steps stored for the current local date.
  int get currentSteps => _currentSteps;

  /// Timestamp of the most recently stored step.
  DateTime? get lastStepTimestamp => _lastStepTimestamp;

  bool get isRunning => _isRunning;

  Stream<int> get stepCountStream => _stepCountController.stream;

  /// Emits one record for every newly detected step.
  Stream<StepRecord> get stepStream => _stepController.stream;

  Stream<Object> get errorStream => _errorController.stream;

  Future<void> start() async {
    _ensureNotDisposed();

    if (_isRunning) {
      return;
    }

    await _requestPermission();
    await repository.initialize();

    final now = DateTime.now();
    _currentDateKey = _dateKey(now);
    _currentSteps = await repository.getStepCount(now);

    final persistedState = await repository.getRawSensorState();

    if (persistedState != null) {
      _lastRawStepCount = persistedState.rawStepCount;
      _lastSensorTimestamp = persistedState.timestamp;
    }

    _stepCountController.add(_currentSteps);

    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (Object error, StackTrace stackTrace) {
        if (!_errorController.isClosed) {
          _errorController.add(error);
        }
      },
    );

    _isRunning = true;
  }

  void _onStepCount(StepCount event) {
    _processing = _processing.then((_) => _processStepCount(event));

    _processing = _processing.catchError(
      (Object error, StackTrace stackTrace) {
        if (!_errorController.isClosed) {
          _errorController.add(error);
        }
      },
    );
  }

  Future<void> _processStepCount(StepCount event) async {
    final rawSteps = event.steps;
    final eventTimestamp = event.timeStamp.toLocal();

    if (_lastRawStepCount == null || _lastSensorTimestamp == null) {
      await _setSensorBaseline(
        rawSteps: rawSteps,
        timestamp: eventTimestamp,
      );
      return;
    }

    final difference = rawSteps - _lastRawStepCount!;

    // A negative delta means the underlying cumulative OS counter reset,
    // usually because the device rebooted. Establish a new baseline.
    if (difference <= 0) {
      await _setSensorBaseline(
        rawSteps: rawSteps,
        timestamp: eventTimestamp,
      );
      return;
    }

    final records = _createStepRecords(
      count: difference,
      previousTimestamp: _lastSensorTimestamp!,
      currentTimestamp: eventTimestamp,
    );

    await repository.addSteps(records);

    for (final record in records) {
      _lastStepTimestamp = record.timestamp;

      if (!_stepController.isClosed) {
        _stepController.add(record);
      }
    }

    await _updateCurrentDayCount(records);

    await _setSensorBaseline(
      rawSteps: rawSteps,
      timestamp: eventTimestamp,
    );
  }

  /// Creates individual records from a cumulative pedometer delta.
  ///
  /// The platform pedometer does not provide a true timestamp for every
  /// physical step. If multiple steps are reported together, timestamps are
  /// distributed across the period since the previous sensor event and marked
  /// as estimated.
  List<StepRecord> _createStepRecords({
    required int count,
    required DateTime previousTimestamp,
    required DateTime currentTimestamp,
  }) {
    if (count <= 0) {
      return const [];
    }

    if (count == 1) {
      return [
        StepRecord(
          timestamp: currentTimestamp,
          isEstimated: false,
        ),
      ];
    }

    if (!currentTimestamp.isAfter(previousTimestamp)) {
      return List<StepRecord>.generate(
        count,
        (_) => StepRecord(
          timestamp: currentTimestamp,
          isEstimated: true,
        ),
        growable: false,
      );
    }

    final startMicros = previousTimestamp.microsecondsSinceEpoch;
    final endMicros = currentTimestamp.microsecondsSinceEpoch;
    final durationMicros = endMicros - startMicros;

    return List<StepRecord>.generate(
      count,
      (index) {
        final stepNumber = index + 1;
        final timestampMicros =
            startMicros + ((durationMicros * stepNumber) ~/ count);

        return StepRecord(
          timestamp: DateTime.fromMicrosecondsSinceEpoch(timestampMicros),
          isEstimated: true,
        );
      },
      growable: false,
    );
  }

  Future<void> _updateCurrentDayCount(List<StepRecord> newSteps) async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    if (_currentDateKey != todayKey) {
      _currentDateKey = todayKey;
      _currentSteps = await repository.getStepCount(now);
    } else {
      _currentSteps += newSteps
          .where((step) => _dateKey(step.timestamp) == todayKey)
          .length;
    }

    if (!_stepCountController.isClosed) {
      _stepCountController.add(_currentSteps);
    }
  }

  Future<void> _setSensorBaseline({
    required int rawSteps,
    required DateTime timestamp,
  }) async {
    _lastRawStepCount = rawSteps;
    _lastSensorTimestamp = timestamp;

    await repository.saveRawSensorState(
      rawStepCount: rawSteps,
      timestamp: timestamp,
    );
  }

  Future<void> _requestPermission() async {
    if (!Platform.isAndroid) {
      return;
    }

    var status = await Permission.activityRecognition.status;

    if (status.isGranted) {
      return;
    }

    status = await Permission.activityRecognition.request();

    if (!status.isGranted) {
      throw const StepPermissionException(
        'Activity recognition permission was not granted.',
      );
    }
  }

  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }

    await _stepCountSubscription?.cancel();
    _stepCountSubscription = null;
    _isRunning = false;
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    await stop();
    await _processing;

    await _stepCountController.close();
    await _stepController.close();
    await _errorController.close();

    if (_ownsRepository) {
      await repository.close();
    }

    _isDisposed = true;
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('StepCounter has already been disposed.');
    }
  }

  static String _dateKey(DateTime date) {
    final local = date.toLocal();

    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

class StepPermissionException implements Exception {
  final String message;

  const StepPermissionException(this.message);

  @override
  String toString() => 'StepPermissionException: $message';
}
