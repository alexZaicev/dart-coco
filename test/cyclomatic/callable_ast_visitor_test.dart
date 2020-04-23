library dart_coco.cyclomatic.test;

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_coco/cyclomatic/cyclomatic.dart';
import 'package:test/test.dart';

const String _TEST_COMP_UNIT = '''
class A {
  void method() {
    if(a()) {
      print("a");
    } else {
      print("b");
    }
    if(b()){
      print("c");
    } else {
      print("d");
    }
  }
}

main() {}
''';

bool _functionDeclarationFilter(ScopedDeclaration dec) {
  return dec.declaration is FunctionDeclaration;
}

bool _methodDeclarationFilter(ScopedDeclaration dec) {
  return dec.declaration is MethodDeclaration;
}

main() {
  group('Callable AST visitor', () {
    ParseStringResult parseStringResult;
    CompilationUnit compUnit;
    CallableAstVisitor callableVisitor;

    setUp(() {
      parseStringResult = parseString(content: _TEST_COMP_UNIT);
      compUnit = parseStringResult.unit;
      callableVisitor = CallableAstVisitor();
      compUnit.visitChildren(callableVisitor);
    });

    test('AST visit call', () {
      expect(() {
        compUnit.visitChildren(callableVisitor);
      }, returnsNormally);
    });

    test('Function found', () {
      expect(callableVisitor.declarations.where(_functionDeclarationFilter).length, greaterThan(0));
    });

    test('Method found', () {
      expect(callableVisitor.declarations.where(_methodDeclarationFilter).length, greaterThan(0));
    });

    test('Method found', () {
      expect(callableVisitor.declarations.length, 2);
    });
  });
}
