class StepRecord {
  final int? id;
  final DateTime timestamp;

  /// True when the operating system reported several steps in one batch and
  /// the exact timestamp of this individual physical step was unavailable.
  final bool isEstimated;

  const StepRecord({
    this.id,
    required this.timestamp,
    this.isEstimated = false,
  });

  Map<String, Object?> toMap() {
    final localTimestamp = timestamp.toLocal();

    return {
      if (id != null) 'id': id,
      'timestamp_ms': timestamp.millisecondsSinceEpoch,
      'local_date': _dateKey(localTimestamp),
      'local_hour': localTimestamp.hour,
      'is_estimated': isEstimated ? 1 : 0,
    };
  }

  factory StepRecord.fromMap(Map<String, Object?> map) {
    return StepRecord(
      id: map['id'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp_ms'] as int,
      ),
      isEstimated: (map['is_estimated'] as int? ?? 0) == 1,
    );
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
