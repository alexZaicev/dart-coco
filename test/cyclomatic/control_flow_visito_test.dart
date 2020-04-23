library dart_coco.cyclomatic.test;

import 'package:dart_coco/cyclomatic/cyclomatic.dart';
import 'package:test/test.dart';

Future main() async {
  group('Control flow AST visitor', () {
    test('Complexity increment with known config option', () {
      final visitor = ControlFlowVisitor(DEFAULT_CYCLOMATIC_CONFIG);
      expect(visitor.complexity, 1);
      expect(() {
        visitor.increaseComplexity('ifStatement');
      }, returnsNormally);
      expect(visitor.complexity, 2);
    });

    test('Complexity increment with unknown config option', () {
      final visitor = ControlFlowVisitor(DEFAULT_CYCLOMATIC_CONFIG);
      expect(() {
        visitor.increaseComplexity('unknownoption');
      }, throwsArgumentError);
      expect(visitor.complexity, 1);
    });
  });
}
