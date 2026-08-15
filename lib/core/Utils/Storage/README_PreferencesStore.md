# PreferencesStore

`PreferencesStore` is a small cross-platform utility for storing simple, non-sensitive key-value data in the Flutter app.

It wraps Flutter's `shared_preferences` package and intentionally exposes only the operations normally needed for preferences:

```text
set()
get<T>()
remove()
contains()
clear()
getAll()
```

There are no separate `create()` and `update()` methods because preferences use **upsert** behavior:

- If a key does not exist, `set()` creates it.
- If a key already exists, `set()` replaces its value.

---

## 1. Dependencies

Add `shared_preferences`:

```bash
flutter pub add shared_preferences
```

For the unit tests, also add the platform interface as a development dependency:

```bash
flutter pub add --dev shared_preferences_platform_interface
```

Then resolve dependencies:

```bash
flutter pub get
```

---

## 2. Project location

The utility is located at:

```text
lib/
└── core/
    └── Utils/
        └── Storage/
            └── preferences_store.dart
```

Import it with:

```dart
import 'package:sol_app/core/Utils/Storage/preferences_store.dart';
```

The unit test is located at:

```text
test/
└── core/
    └── Utils/
        └── Storage/
            └── preferences_store_test.dart
```

---

## 3. Async behavior

`PreferencesStore` uses `SharedPreferencesAsync`.

That means preference operations are asynchronous and should normally be called with `await`.

Example:

```dart
await PreferencesStore.set(
  key: 'username',
  value: 'Maor',
);

final String? username =
    await PreferencesStore.get<String>('username');
```

No manual initialization method is required.

---

## 4. Supported value types

The utility supports the native `shared_preferences` value types:

```text
String
bool
int
double
List<String>
```

Examples:

```dart
await PreferencesStore.set(
  key: 'username',
  value: 'Maor',
);

await PreferencesStore.set(
  key: 'dark_mode',
  value: true,
);

await PreferencesStore.set(
  key: 'last_selected_tab',
  value: 2,
);

await PreferencesStore.set(
  key: 'text_scale',
  value: 1.2,
);

await PreferencesStore.set(
  key: 'favorite_categories',
  value: <String>['technology', 'sports'],
);
```

Arbitrary Dart objects are not supported directly.

For complex objects, use another persistence solution or explicitly serialize the data when appropriate.

---

## 5. set()

`set()` creates or replaces a value.

```dart
await PreferencesStore.set(
  key: 'username',
  value: 'Maor',
);
```

If `username` does not exist, it is created.

Calling:

```dart
await PreferencesStore.set(
  key: 'username',
  value: 'David',
);
```

replaces the existing value.

This is similar to Android `SharedPreferences.Editor.putString()` behavior.

---

## 6. get<T>()

Read a value by specifying the expected type:

```dart
final String? username =
    await PreferencesStore.get<String>(
  'username',
);
```

Examples:

```dart
final bool? darkMode =
    await PreferencesStore.get<bool>(
  'dark_mode',
);

final int? selectedTab =
    await PreferencesStore.get<int>(
  'last_selected_tab',
);

final double? textScale =
    await PreferencesStore.get<double>(
  'text_scale',
);

final List<String>? categories =
    await PreferencesStore.get<List<String>>(
  'favorite_categories',
);
```

### Missing key

If the key does not exist, `get<T>()` returns `null`.

```dart
final String? value =
    await PreferencesStore.get<String>(
  'missing_key',
);
```

Result:

```text
null
```

### Wrong requested type

If the key exists but the requested type does not match the stored type, `PreferencesStore` throws a `StateError`.

Example:

```dart
await PreferencesStore.set(
  key: 'age',
  value: 25,
);
```

Correct:

```dart
final int? age =
    await PreferencesStore.get<int>('age');
```

Incorrect:

```dart
final String? age =
    await PreferencesStore.get<String>('age');
```

The second call throws a `StateError`.

---

## 7. remove()

Remove a value:

```dart
await PreferencesStore.remove(
  'username',
);
```

Removing a key that does not exist is harmless.

---

## 8. contains()

Check whether a key exists:

```dart
final bool exists =
    await PreferencesStore.contains(
  'username',
);
```

---

## 9. getAll()

Get all stored key-value pairs:

```dart
final Map<String, Object?> values =
    await PreferencesStore.getAll();
```

This is mainly useful for:

```text
Debugging
Diagnostics
Inspection tools
Administrative screens
```

It should not normally be used when only one specific value is needed.

---

## 10. clear()

Remove all stored preferences:

```dart
await PreferencesStore.clear();
```

Use this carefully.

`clear()` removes all preferences in this store.

For example, during logout you may want to remove only account-related values with `remove()` while preserving app-wide settings such as:

```text
Theme
Language
Accessibility preferences
UI configuration
```

Do not use `clear()` automatically unless removing every preference is the intended behavior.

---

## 11. Adding a new/manual field

A developer can introduce a new preference without changing `PreferencesStore`.

Example:

```dart
await PreferencesStore.set(
  key: 'show_tutorial',
  value: false,
);
```

Read it later:

```dart
final bool? showTutorial =
    await PreferencesStore.get<bool>(
  'show_tutorial',
);
```

No additional method needs to be added to the utility class.

---

## 12. Optional key constants

For keys used in multiple places, defining constants elsewhere in the project can prevent spelling inconsistencies.

Example:

```dart
class PreferenceKeys {
  PreferenceKeys._();

  static const String username = 'username';
  static const String darkMode = 'dark_mode';
}
```

Usage:

```dart
await PreferencesStore.set(
  key: PreferenceKeys.username,
  value: 'Maor',
);
```

Recommended approach:

```text
Local / one-off field       -> direct String key is acceptable
Shared / established field  -> use a key constant
```

---

## 13. Validation behavior

`PreferencesStore` validates its inputs.

### Empty keys

Empty or whitespace-only keys are rejected:

```dart
await PreferencesStore.set(
  key: '   ',
  value: 'value',
);
```

This throws an `ArgumentError`.

### Unsupported values

Unsupported types are also rejected.

Example:

```dart
await PreferencesStore.set(
  key: 'user',
  value: <String, Object>{
    'name': 'Maor',
  },
);
```

This throws an `ArgumentError`.

Supported values remain limited to:

```text
String
bool
int
double
List<String>
```

---

## 14. Android developer mapping

Conceptually:

| Android SharedPreferences | PreferencesStore |
|---|---|
| `putString()` / `putBoolean()` / etc. | `set()` |
| `getString()` / `getBoolean()` / etc. | `get<T>()` |
| `remove()` | `remove()` |
| `contains()` | `contains()` |
| `clear()` | `clear()` |
| inspect all values | `getAll()` |

Android/Kotlin:

```kotlin
sharedPreferences
    .edit()
    .putString("username", "Maor")
    .apply()
```

Flutter:

```dart
await PreferencesStore.set(
  key: 'username',
  value: 'Maor',
);
```

---

## 15. Cross-platform behavior

`PreferencesStore` contains no Android-specific code.

The `shared_preferences` package provides the platform-specific persistence implementation underneath the same Dart API.

The utility can therefore be used on supported Flutter platforms such as:

```text
Android
iOS
macOS
Windows
Linux
Web
```

The application does not need separate `PreferencesStore` implementations for Android and iOS.

---

## 16. Appropriate use

Good uses include:

```text
Theme
Language
First-launch flag
Last selected screen or tab
Feature settings
Small IDs
Boolean flags
Simple UI preferences
```

Do not use preferences for:

```text
Passwords
Authentication secrets
Sensitive credentials
Large datasets
Images
Complex database records
Critical data requiring stronger persistence guarantees
```

Use secure storage for secrets and a database or file-storage solution for larger or structured data.

---

## 17. Unit tests

The unit tests use an in-memory implementation of the SharedPreferences platform interface.

This keeps the tests:

```text
Fast
Deterministic
Independent of Android or iOS
Independent of an emulator
Independent of real device storage
```

The tests currently verify:

```text
String storage
bool storage
int storage
double storage
List<String> storage
set() overwrite behavior
Missing-key behavior
Wrong-type handling
contains()
remove()
getAll()
clear()
Empty-key validation
Unsupported-type validation
```

Run all tests:

```bash
flutter test
```

Run only the `PreferencesStore` test file:

```bash
flutter test test/core/Utils/Storage/preferences_store_test.dart
```

A successful run should end with:

```text
All tests passed!
```

---

## 18. Unit tests vs real persistence tests

The unit tests validate the behavior of `PreferencesStore`, but they do **not** verify actual Android or iOS disk persistence.

The in-memory test backend does not persist data across app restarts.

Actual persistence should be verified separately with an integration test or a manual device test.

Example persistence check:

1. Store a value.
2. Close the application completely.
3. Reopen the application.
4. Read the same key.
5. Verify that the value still exists.

That kind of test verifies the real platform implementation rather than only the Dart wrapper.

---

## API summary

```dart
PreferencesStore.set(...)
PreferencesStore.get<T>(...)
PreferencesStore.remove(...)
PreferencesStore.contains(...)
PreferencesStore.clear()
PreferencesStore.getAll()
```

The class is intentionally kept small so developers do not have to choose between multiple methods that perform nearly the same operation.
