part of dart_coco.logger;

enum LogLevel { ERROR, WARN, INFO, DEBUG }

class Logger {
  String _tag;

  static LogLevel logLevel = LogLevel.INFO;

  static final _allowed = <LogLevel, List<LogLevel>>{
    LogLevel.ERROR: [LogLevel.ERROR],
    LogLevel.WARN: [LogLevel.ERROR, LogLevel.WARN],
    LogLevel.INFO: [LogLevel.ERROR, LogLevel.WARN, LogLevel.INFO],
    LogLevel.DEBUG: [
      LogLevel.ERROR,
      LogLevel.WARN,
      LogLevel.INFO,
      LogLevel.DEBUG
    ],
  };

  Logger(final String tag) {
    _tag = tag;
  }

  void e(final String msg) {
    _print(LogLevel.ERROR, msg);
  }

  void w(final String msg) {
    _print(LogLevel.WARN, msg);
  }

  void i(final String msg) {
    _print(LogLevel.INFO, msg);
  }

  void d(final String msg) {
    _print(LogLevel.DEBUG, msg);
  }

  void _print(final LogLevel lvl, final String msg) {
    if (_allowed[logLevel].contains(lvl)) {
      print(
          '${_timestamp()}\t --- [${EnumToString.parse(lvl)}] --- [$_tag] --- $msg');
    }
  }

  String _timestamp() {
    final DateFormat ff = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateTime now = DateTime.now();
    return ff.format(now);
  }
}
