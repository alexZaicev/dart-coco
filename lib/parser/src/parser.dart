part of dart_coco.parser;

abstract class Parser {
  Future<dynamic> convert(final String data);
}

class ParserError implements Exception {
  ParserError(final String msg);
}

abstract class Serializable<T> {

  Map<String, dynamic> toMap();

}