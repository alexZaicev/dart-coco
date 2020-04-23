# Dart-CoCo ![Coverage](https://raw.githubusercontent.com/alexZaicev/dart-coco/master/coverage_badge.svg?sanitize=true)

Dart-CoCo for [Dart](https://www.dartlang.org/) is a simple command line utility providing insights into:
 * quality of code by using static analysis of the code to calculate 
[cyclomatic complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity) value.
 * coverage information generated from `lcov.info` file.  

## How to use

In `pubspec.yaml` add a development dependency:
```
dev-dependencies:
    dart_coco: ^1.0.1
```

From command line execute:
```
flutter pub run dart_coco --html
```
If you run `flutter test --coverage` before executing Dart-CoCo, tool will include coverage data gathered inside `coverage/lcov.info`

#####Directly from GitHub clone:

```
git clone https://github.com/alexZaicev/dart-coco.git
cd dart-coco
pub get

dart bin/dart_coco.dart --html -r path/to/lib -o report --lcov path/to/lcov.info
```

## Options

 * --root (-r) - package root containing modules with dart files to analyse
 * --output (-o) - report output directory location
 * --html - HTML report format
 * --json - JSON report format
 * --help (-h) - Help page
 * --verbose (-v) - Enable detailed logging
 * --lcov - path to LCOV coverage report file
