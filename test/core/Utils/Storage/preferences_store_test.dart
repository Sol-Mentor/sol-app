import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sol_app/core/Utils/Storage/preferences_store.dart';

void main() {
  setUpAll(() {
    // PreferencesStore creates its SharedPreferencesAsync instance lazily.
    // Set the in-memory backend before PreferencesStore is accessed.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  setUp(() async {
    // Keep every test independent.
    await PreferencesStore.clear();
  });

  group('PreferencesStore', () {
    group('set / get', () {
      test('stores and reads a String', () async {
        await PreferencesStore.set(
          key: 'username',
          value: 'Maor',
        );

        final String? value =
        await PreferencesStore.get<String>('username');

        expect(value, 'Maor');
      });

      test('stores and reads a bool', () async {
        await PreferencesStore.set(
          key: 'dark_mode',
          value: true,
        );

        final bool? value =
        await PreferencesStore.get<bool>('dark_mode');

        expect(value, true);
      });

      test('stores and reads an int', () async {
        await PreferencesStore.set(
          key: 'selected_tab',
          value: 2,
        );

        final int? value =
        await PreferencesStore.get<int>('selected_tab');

        expect(value, 2);
      });

      test('stores and reads a double', () async {
        await PreferencesStore.set(
          key: 'text_scale',
          value: 1.25,
        );

        final double? value =
        await PreferencesStore.get<double>('text_scale');

        expect(value, 1.25);
      });

      test('stores and reads a List<String>', () async {
        const List<String> expected = <String>[
          'technology',
          'sports',
        ];

        await PreferencesStore.set(
          key: 'categories',
          value: expected,
        );

        final List<String>? value =
        await PreferencesStore.get<List<String>>('categories');

        expect(value, expected);
      });

      test('set replaces an existing value', () async {
        await PreferencesStore.set(
          key: 'username',
          value: 'Maor',
        );

        await PreferencesStore.set(
          key: 'username',
          value: 'David',
        );

        final String? value =
        await PreferencesStore.get<String>('username');

        expect(value, 'David');
      });

      test('get returns null when the key does not exist', () async {
        final String? value =
        await PreferencesStore.get<String>('missing_key');

        expect(value, isNull);
      });

      test('get throws StateError when the requested type is wrong', () async {
        await PreferencesStore.set(
          key: 'age',
          value: 25,
        );

        await expectLater(
          PreferencesStore.get<String>('age'),
          throwsA(isA<StateError>()),
        );
      });
    });

    test('contains reports whether a key exists', () async {
      expect(
        await PreferencesStore.contains('username'),
        isFalse,
      );

      await PreferencesStore.set(
        key: 'username',
        value: 'Maor',
      );

      expect(
        await PreferencesStore.contains('username'),
        isTrue,
      );
    });

    test('remove deletes a stored value', () async {
      await PreferencesStore.set(
        key: 'username',
        value: 'Maor',
      );

      await PreferencesStore.remove('username');

      expect(
        await PreferencesStore.get<String>('username'),
        isNull,
      );

      expect(
        await PreferencesStore.contains('username'),
        isFalse,
      );
    });

    test('getAll returns all stored values', () async {
      await PreferencesStore.set(
        key: 'username',
        value: 'Maor',
      );

      await PreferencesStore.set(
        key: 'dark_mode',
        value: true,
      );

      final Map<String, Object?> values =
      await PreferencesStore.getAll();

      expect(
        values,
        containsPair('username', 'Maor'),
      );

      expect(
        values,
        containsPair('dark_mode', true),
      );
    });

    test('clear removes all stored values', () async {
      await PreferencesStore.set(
        key: 'username',
        value: 'Maor',
      );

      await PreferencesStore.set(
        key: 'dark_mode',
        value: true,
      );

      await PreferencesStore.clear();

      expect(
        await PreferencesStore.getAll(),
        isEmpty,
      );
    });

    group('validation', () {
      test('rejects an empty key', () async {
        await expectLater(
          PreferencesStore.set(
            key: '   ',
            value: 'value',
          ),
          throwsArgumentError,
        );
      });

      test('rejects an unsupported value type', () async {
        await expectLater(
          PreferencesStore.set(
            key: 'unsupported',
            value: <String, Object>{'value': 1},
          ),
          throwsArgumentError,
        );
      });
    });
  });
}