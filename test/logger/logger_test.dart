library dart_coco.cyclomatic.test;

import 'package:dart_coco/logger/logger.dart';
import 'package:test/test.dart';

Future main() async {
  test('Logger test void methods', () {
    final _logger = Logger('Test');

    Logger.logLevel = LogLevel.ERROR;
    _logger.e('Test error message');
    _logger.w('Test warn message');
    _logger.i('Test info message');
    _logger.d('Test debug message');

    Logger.logLevel = LogLevel.WARN;
    _logger.e('Test error message');
    _logger.w('Test warn message');
    _logger.i('Test info message');
    _logger.d('Test debug message');

    Logger.logLevel = LogLevel.INFO;
    _logger.e('Test error message');
    _logger.w('Test warn message');
    _logger.i('Test info message');
    _logger.d('Test debug message');

    Logger.logLevel = LogLevel.DEBUG;
    _logger.e('Test error message');
    _logger.w('Test warn message');
    _logger.i('Test info message');
    _logger.d('Test debug message');
  });
}