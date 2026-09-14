import 'package:shared_preferences/shared_preferences.dart';

/// Cross-platform utility for storing small, non-sensitive key-value data.
///
/// Supported value types:
/// - String
/// - bool
/// - int
/// - double
/// - List<String>
///
/// Uses [SharedPreferencesAsync], so no initialization in `main()` is required.
class PreferencesStore {
  PreferencesStore._();

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  /// Creates or replaces a value.
  ///
  /// Example:
  /// ```dart
  /// await PreferencesStore.set(
  ///   key: 'username',
  ///   value: 'Maor',
  /// );
  /// ```
  static Future<void> set({
    required String key,
    required Object value,
  }) async {
    _validateKey(key);

    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw ArgumentError(
        'Unsupported type: ${value.runtimeType}. '
        'Supported types are String, bool, int, double, and List<String>.',
      );
    }
  }

  /// Returns the value stored under [key] as [T].
  ///
  /// Returns `null` if the key does not exist.
  ///
  /// Throws [StateError] if the stored value exists but does not match [T].
  ///
  /// Example:
  /// ```dart
  /// final String? username =
  ///     await PreferencesStore.get<String>('username');
  /// ```
  static Future<T?> get<T>(String key) async {
    _validateKey(key);

    try {
      Object? value;

      if (T == String) {
        value = await _prefs.getString(key);
      } else if (T == bool) {
        value = await _prefs.getBool(key);
      } else if (T == int) {
        value = await _prefs.getInt(key);
      } else if (T == double) {
        value = await _prefs.getDouble(key);
      } else if (T == List<String>) {
        value = await _prefs.getStringList(key);
      } else {
        throw ArgumentError(
          'Unsupported type: $T. '
              'Supported types are String, bool, int, double, and List<String>.',
        );
      }

      return value as T?;
    } on TypeError {
      throw StateError(
        'Preference "$key" does not contain the requested type $T.',
      );
    }
  }

  /// Removes [key].
  ///
  /// Removing a key that does not exist is harmless.
  ///
  /// Example:
  /// ```dart
  /// await PreferencesStore.remove('username');
  /// ```
  static Future<void> remove(String key) async {
    _validateKey(key);
    await _prefs.remove(key);
  }

  /// Returns `true` if [key] exists.
  ///
  /// Example:
  /// ```dart
  /// final bool exists =
  ///     await PreferencesStore.contains('username');
  /// ```
  static Future<bool> contains(String key) async {
    _validateKey(key);
    return _prefs.containsKey(key);
  }

  /// Removes all stored preferences.
  ///
  /// Use carefully.
  static Future<void> clear() async {
    await _prefs.clear();
  }

  /// Returns all stored key-value pairs.
  ///
  /// Mainly useful for debugging or diagnostics.
  static Future<Map<String, Object?>> getAll() async {
    return _prefs.getAll();
  }

  static void _validateKey(String key) {
    if (key.trim().isEmpty) {
      throw ArgumentError('Preference key cannot be empty.');
    }
  }
}
