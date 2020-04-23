part of dart_coco.cyclomatic;

class ScopedDeclaration {
  ScopedDeclaration(this.declaration, this.enclosingClass);

  final Declaration declaration;
  final ClassDeclaration enclosingClass;
}

///
/// Recursive AST visitor implementation to collect methods/functions
///
class CallableAstVisitor extends RecursiveAstVisitor<Object> {
  final List<ScopedDeclaration> _declarations = [];

  ClassDeclaration enclosingClass;

  BuiltList<ScopedDeclaration> get declarations => BuiltList<ScopedDeclaration>(_declarations);

  void registerDeclaration(Declaration node) {
    _declarations.add(ScopedDeclaration(node, enclosingClass));
  }

  @override
  Object visitFunctionDeclaration(FunctionDeclaration node) {
    registerDeclaration(node);
    super.visitFunctionDeclaration(node);
    return null;
  }

  @override
  Object visitMethodDeclaration(MethodDeclaration node) {
    registerDeclaration(node);
    super.visitMethodDeclaration(node);
    return null;
  }

  @override
  Object visitClassDeclaration(ClassDeclaration node) {
    enclosingClass = node;
    super.visitClassDeclaration(node);
    enclosingClass = null;
    return null;
  }
}
