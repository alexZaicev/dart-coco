part of dart_coco.parser;

abstract class Parser {
  Future<dynamic> convert(final String convertData);
}

class ParserError implements Exception {
  ParserError(final String msg) : _msg = msg;

  final String _msg;

  @override
  String toString() {
    return 'ParserError: $_msg';
  }
}

abstract class Serializable<T> {
  Map<String, dynamic> toMap();
}
