part of dart_coco.cyclomatic;

class ControlFlowVisitor extends RecursiveAstVisitor<Object> {
  ControlFlowVisitor(this.config);

  int _complexity = 1;

  int get complexity => _complexity;

  final CyclomaticConfig config;

  void increaseComplexity(String configOptionToConsider) {
    if (!CyclomaticConfig.CYCLOMATIC_CONFIG_OPTIONS
        .contains(configOptionToConsider)) {
      throw ArgumentError.value(configOptionToConsider);
    }
    _complexity +=
        config.addedComplexityByControlFlowType[configOptionToConsider];
  }

  @override
  Object visitAssertStatement(AssertStatement node) {
    increaseComplexity('assertStatement');
    super.visitAssertStatement(node);
    return null;
  }

  @override
  Object visitBlockFunctionBody(BlockFunctionBody node) {
    Token tok = node.beginToken;
    while (tok != node.block.rightBracket) {
      if (tok.matchesAny(
          const [TokenType.AMPERSAND_AMPERSAND, TokenType.BAR_BAR])) {
        increaseComplexity('blockFunctionBody');
      }
      tok = tok.next;
    }
    super.visitBlockFunctionBody(node);
    return null;
  }

  @override
  Object visitCatchClause(CatchClause node) {
    increaseComplexity('catchClause');
    super.visitCatchClause(node);
    return null;
  }

  @override
  Object visitConditionalExpression(ConditionalExpression node) {
    increaseComplexity('conditionalExpression');
    super.visitConditionalExpression(node);
    return null;
  }

  @override
  Object visitForStatement(ForStatement node) {
    increaseComplexity('forStatement');
    super.visitForStatement(node);
    return null;
  }

  @override
  Object visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    increaseComplexity('forEachStatement');
    super.visitForEachPartsWithDeclaration(node);
    return null;
  }

  @override
  Object visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    increaseComplexity('forEachStatement');
    super.visitForEachPartsWithIdentifier(node);
    return null;
  }

  @override
  Object visitIfStatement(IfStatement node) {
    increaseComplexity('ifStatement');
    super.visitIfStatement(node);
    return null;
  }

  @override
  Object visitSwitchDefault(SwitchDefault node) {
    increaseComplexity('switchDefault');
    super.visitSwitchDefault(node);
    return null;
  }

  @override
  Object visitSwitchCase(SwitchCase node) {
    increaseComplexity('switchCase');
    super.visitSwitchCase(node);
    return null;
  }

  @override
  Object visitWhileStatement(WhileStatement node) {
    increaseComplexity('whileStatement');
    super.visitWhileStatement(node);
    return null;
  }

  @override
  Object visitYieldStatement(YieldStatement node) {
    increaseComplexity('yieldStatement');
    super.visitYieldStatement(node);
    return null;
  }
}
