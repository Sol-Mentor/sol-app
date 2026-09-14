import 'package:sqflite/sqflite.dart';

import 'step_record.dart';

class StepRepository {
  static const String _databaseName = 'step_counter.db';
  static const int _databaseVersion = 1;

  static const String _stepsTable = 'step_events';
  static const String _metadataTable = 'step_metadata';

  static const String _rawCountKey = 'last_raw_step_count';
  static const String _rawTimestampKey = 'last_raw_timestamp_ms';

  Database? _database;

  Future<void> initialize() async {
    await _getDatabase();
  }

  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    _database = await openDatabase(
      _databaseName,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_stepsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp_ms INTEGER NOT NULL,
            local_date TEXT NOT NULL,
            local_hour INTEGER NOT NULL,
            is_estimated INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_step_date_hour
          ON $_stepsTable(local_date, local_hour)
        ''');

        await db.execute('''
          CREATE INDEX idx_step_timestamp
          ON $_stepsTable(timestamp_ms)
        ''');

        await db.execute('''
          CREATE TABLE $_metadataTable (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<void> addStep(StepRecord step) async {
    final db = await _getDatabase();

    await db.insert(
      _stepsTable,
      step.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> addSteps(List<StepRecord> steps) async {
    if (steps.isEmpty) {
      return;
    }

    final db = await _getDatabase();
    final batch = db.batch();

    for (final step in steps) {
      batch.insert(
        _stepsTable,
        step.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Returns the number of stored steps for [date].
  ///
  /// If [hour] is supplied, only steps from that local hour (0-23) are counted.
  Future<int> getStepCount(
    DateTime date, {
    int? hour,
    bool includeEstimated = true,
  }) async {
    _validateHour(hour);

    final db = await _getDatabase();
    final where = <String>['local_date = ?'];
    final args = <Object?>[_dateKey(date)];

    if (hour != null) {
      where.add('local_hour = ?');
      args.add(hour);
    }

    if (!includeEstimated) {
      where.add('is_estimated = 0');
    }

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM $_stepsTable
      WHERE ${where.join(' AND ')}
      ''',
      args,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<StepRecord>> getSteps(
    DateTime date, {
    int? hour,
    bool includeEstimated = true,
  }) async {
    _validateHour(hour);

    final db = await _getDatabase();
    final where = <String>['local_date = ?'];
    final args = <Object?>[_dateKey(date)];

    if (hour != null) {
      where.add('local_hour = ?');
      args.add(hour);
    }

    if (!includeEstimated) {
      where.add('is_estimated = 0');
    }

    final rows = await db.query(
      _stepsTable,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'timestamp_ms ASC',
    );

    return rows.map(StepRecord.fromMap).toList(growable: false);
  }

  Future<List<DateTime>> getStepTimestamps(
    DateTime date, {
    int? hour,
    bool includeEstimated = true,
  }) async {
    final steps = await getSteps(
      date,
      hour: hour,
      includeEstimated: includeEstimated,
    );

    return steps.map((step) => step.timestamp).toList(growable: false);
  }

  /// Stores the most recent cumulative pedometer value and timestamp.
  ///
  /// This allows the counter to continue calculating deltas after an app
  /// restart rather than treating every app launch as a brand-new baseline.
  Future<void> saveRawSensorState({
    required int rawStepCount,
    required DateTime timestamp,
  }) async {
    final db = await _getDatabase();

    await db.transaction((txn) async {
      await txn.insert(
        _metadataTable,
        {'key': _rawCountKey, 'value': rawStepCount.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        _metadataTable,
        {
          'key': _rawTimestampKey,
          'value': timestamp.millisecondsSinceEpoch.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<RawStepSensorState?> getRawSensorState() async {
    final db = await _getDatabase();

    final rows = await db.query(
      _metadataTable,
      where: 'key IN (?, ?)',
      whereArgs: [_rawCountKey, _rawTimestampKey],
    );

    if (rows.length < 2) {
      return null;
    }

    final values = <String, String>{};

    for (final row in rows) {
      values[row['key'] as String] = row['value'] as String;
    }

    final rawCount = int.tryParse(values[_rawCountKey] ?? '');
    final timestampMs = int.tryParse(values[_rawTimestampKey] ?? '');

    if (rawCount == null || timestampMs == null) {
      return null;
    }

    return RawStepSensorState(
      rawStepCount: rawCount,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );
  }

  Future<void> clear() async {
    final db = await _getDatabase();

    await db.transaction((txn) async {
      await txn.delete(_stepsTable);
      await txn.delete(_metadataTable);
    });
  }

  Future<void> close() async {
    final db = _database;
    _database = null;

    if (db != null) {
      await db.close();
    }
  }

  static void _validateHour(int? hour) {
    if (hour != null && (hour < 0 || hour > 23)) {
      throw ArgumentError.value(
        hour,
        'hour',
        'Hour must be between 0 and 23.',
      );
    }
  }

  static String _dateKey(DateTime date) {
    final local = date.toLocal();

    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

class RawStepSensorState {
  final int rawStepCount;
  final DateTime timestamp;

  const RawStepSensorState({
    required this.rawStepCount,
    required this.timestamp,
  });
}
