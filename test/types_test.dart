import 'package:dirk/src/types.dart';

import 'package:test/test.dart';

void main() {
  test('import type', () {
    var token = Token(TokenType.$import, "'dart:math' as math");
    expect(token.toString(), "import 'dart:math' as math;");
  });

  //model type is not to be tested
  test('if type', () {
    var token = Token(TokenType.$if, "i < 10",
        children: [Token(TokenType.text, "then do this")]);
    expect(token.toString(), "if (i < 10) {\nres += '''then do this''';}");
  });

  test('for type', () {
    var token = Token(TokenType.$for, "var i = 1; i < 10; i++",
        children: [Token(TokenType.text, "do this")]);
    expect(token.toString(),
        "for (var i = 1; i < 10; i++) {\nres += '''do this''';}");
  });

  test('block type', () {
    var token = Token(TokenType.block, "var i = 10;");
    expect(token.toString(), "var i = 10;");
  });

  test('expression type', () {
    var token = Token(TokenType.expression, "model.print('123')");
    expect(token.toString(), r"res += '''${sanitize(model.print('123'))}''';");
  });

  test('text type', () {
    var token = Token(TokenType.text, "<h1>Title</h1>");
    expect(token.toString(), r"res += '''<h1>Title</h1>''';");
  });

  test('partial type', () {
    var token = Token(TokenType.partial, "'_header'");
    expect(token.toString(), r"res += '''${PartialHeaderView()}''';");
    token = Token(TokenType.partial, "'_header', 'param'");
    expect(token.toString(), r"res += '''${PartialHeaderView('param')}''';");
    token = Token(TokenType.partial, "'_header', 123");
    expect(token.toString(), r"res += '''${PartialHeaderView(123)}''';");
  });
}
