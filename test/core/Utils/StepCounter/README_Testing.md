# Testing note

`StepCounter` depends on the platform pedometer stream and `StepRepository` uses `sqflite`.

For proper automated unit tests, the next recommended refactor is to introduce a small `StepSensor` interface and inject a fake sensor into `StepCounter`. Repository tests can use a database test implementation such as `sqflite_common_ffi`.

Do not write a plain `flutter test` that expects the host computer to provide real pedometer events.
