# Step Counter Utility

Copy these production files into:

```text
lib/core/Utils/StepCounter/
├── step_counter.dart
├── step_record.dart
└── step_repository.dart
```

## Dependencies

Add under `dependencies` in `pubspec.yaml`:

```yaml
pedometer: ^4.2.0
sqflite: ^2.4.3
permission_handler: ^12.0.3
```

Then run:

```bash
flutter pub get
```

## Android

Edit `android/app/src/main/AndroidManifest.xml` and add this directly under `<manifest>` and before `<application>`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

## iOS

Edit `ios/Runner/Info.plist` and add:

```xml
<key>NSMotionUsageDescription</key>
<string>This application uses motion data to count your steps.</string>
```

## Initialize once

Do not create a separate `StepCounter` for each screen.

```dart
final stepRepository = StepRepository();
final stepCounter = StepCounter(repository: stepRepository);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await stepCounter.start();
  runApp(const SolApp());
}
```

## API

Current number of stored steps for today:

```dart
final steps = stepCounter.currentSteps;
```

Listen for count changes:

```dart
stepCounter.stepCountStream.listen((steps) {
  print('Steps today: $steps');
});
```

Listen to individual step records:

```dart
stepCounter.stepStream.listen((step) {
  print(step.timestamp);
  print(step.isEstimated);
});
```

Count for a date:

```dart
final count = await stepRepository.getStepCount(
  DateTime(2026, 8, 20),
);
```

Count for one hour:

```dart
final count = await stepRepository.getStepCount(
  DateTime(2026, 8, 20),
  hour: 14,
);
```

Timestamps for one hour:

```dart
final timestamps = await stepRepository.getStepTimestamps(
  DateTime(2026, 8, 20),
  hour: 14,
);
```

## Important timestamp limitation

The platform pedometer exposes a cumulative step count, not a guaranteed hardware timestamp for every physical step.

When multiple steps arrive in one sensor update, this utility distributes their timestamps across the interval between the previous and current sensor updates and marks them with `isEstimated: true`.

## Persistence

The repository stores both the step records and the last cumulative pedometer state. This allows a later app session to recover a step-count delta when the OS counter has increased, although timestamps for steps that occurred while no event was being processed are necessarily estimates.

## Platform scope

This implementation is intended for Android and iOS. `sqflite` alone does not provide the same database implementation for Windows/Linux desktop targets.
