part of dart_coco.cyclomatic;

class ControlFlowVisitor extends RecursiveAstVisitor<Object> {
  int _complexity = 1;

  int get complexity => _complexity;

  final CyclomaticConfig config;

  ControlFlowVisitor(this.config);

  void increaseComplexity(String configOptionToConsider) {
    if (!CYCLOMATIC_CONFIG_OPTIONS.contains(configOptionToConsider)) {
      throw new ArgumentError.value(configOptionToConsider);
    }
    _complexity += config.addedComplexityByControlFlowType[configOptionToConsider];
  }

  @override
  visitAssertStatement(AssertStatement node) {
    increaseComplexity('assertStatement');
    super.visitAssertStatement(node);
    return null;
  }

  @override
  visitBlockFunctionBody(BlockFunctionBody node) {
    Token tok = node.beginToken;
    while (tok != node.block.rightBracket) {
      if (tok.matchesAny(const [TokenType.AMPERSAND_AMPERSAND, TokenType.BAR_BAR])) {
        increaseComplexity('blockFunctionBody');
      }
      tok = tok.next;
    }
    super.visitBlockFunctionBody(node);
    return null;
  }

  @override
  visitCatchClause(CatchClause node) {
    increaseComplexity('catchClause');
    super.visitCatchClause(node);
    return null;
  }

  @override
  visitConditionalExpression(ConditionalExpression node) {
    increaseComplexity('conditionalExpression');
    super.visitConditionalExpression(node);
    return null;
  }

  @override
  visitForStatement(ForStatement node) {
    increaseComplexity('forStatement');
    super.visitForStatement(node);
    return null;
  }

  @override
  visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    increaseComplexity('forEachStatement');
    super.visitForEachPartsWithDeclaration(node);
    return null;
  }

  @override
  visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    increaseComplexity('forEachStatement');
    super.visitForEachPartsWithIdentifier(node);
    return null;
  }

  @override
  visitIfStatement(IfStatement node) {
    increaseComplexity('ifStatement');
    super.visitIfStatement(node);
    return null;
  }

  @override
  visitSwitchDefault(SwitchDefault node) {
    increaseComplexity('switchDefault');
    super.visitSwitchDefault(node);
    return null;
  }

  @override
  visitSwitchCase(SwitchCase node) {
    increaseComplexity('switchCase');
    super.visitSwitchCase(node);
    return null;
  }

  @override
  visitWhileStatement(WhileStatement node) {
    increaseComplexity('whileStatement');
    super.visitWhileStatement(node);
    return null;
  }

  @override
  visitYieldStatement(YieldStatement node) {
    increaseComplexity('yieldStatement');
    super.visitYieldStatement(node);
    return null;
  }
}
