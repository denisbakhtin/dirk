import 'package:dirk/src/dirk_ast.dart';
import 'package:dirk/src/types.dart';

import 'package:test/test.dart';

void main() {
  test('import', () {
    var ast = DirkAST(contents: '''@import some_cool_lib
@import    another_cool_lib;''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$import);
    expect(ast.tree[0].content, "some_cool_lib");
    expect(ast.tree[0].children, []);

    expect(ast.tree[1].type, TokenType.$import);
    expect(ast.tree[1].content, "another_cool_lib");
    expect(ast.tree[1].children, []);
  });

  test('model', () {
    var ast = DirkAST(contents: '''@model some_cool_model_type
@model    another_cool_model_type;''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.model);
    expect(ast.tree[0].content, "some_cool_model_type");
    expect(ast.tree[0].children, []);

    expect(ast.tree[1].type, TokenType.model);
    expect(ast.tree[1].content, "another_cool_model_type");
    expect(ast.tree[1].children, []);
  });

  test('if statement', () {
    var ast = DirkAST(contents: '''@if(cond) {
  then do something
}
@if (cond2 ) {
  then do
}''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$if);
    expect(ast.tree[0].content, "cond");
    expect(ast.tree[0].children.length, 1);
    expect(ast.tree[0].children.first.type, TokenType.text);
    expect(ast.tree[0].children.first.content, "then do something ");
    expect(ast.tree[0].children.first.children, []);

    expect(ast.tree[1].type, TokenType.$if);
    expect(ast.tree[1].content, "cond2");
    expect(ast.tree[1].children.length, 1);
    expect(ast.tree[1].children.first.type, TokenType.text);
    expect(ast.tree[1].children.first.content, "then do ");
    expect(ast.tree[1].children.first.children, []);
  });

  test('for statement', () {
    var ast = DirkAST(contents: '''@for(cond) {
  do something
}
@for (var i = 1; i < 10; i++ ) {
  do more
}''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$for);
    expect(ast.tree[0].content, "cond");
    expect(ast.tree[0].children.length, 1);
    expect(ast.tree[0].children.first.type, TokenType.text);
    expect(ast.tree[0].children.first.content, "do something ");
    expect(ast.tree[0].children.first.children, []);

    expect(ast.tree[1].type, TokenType.$for);
    expect(ast.tree[1].content, "var i = 1; i < 10; i++");
    expect(ast.tree[1].children.length, 1);
    expect(ast.tree[1].children.first.type, TokenType.text);
    expect(ast.tree[1].children.first.content, "do more ");
    expect(ast.tree[1].children.first.children, []);
  });

  test('block statement', () {
    var ast = DirkAST(contents: '''@{
  do something
}
@{ do more }''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.block);
    expect(ast.tree[0].content, "do something");
    expect(ast.tree[0].children.length, 0);

    expect(ast.tree[1].type, TokenType.block);
    expect(ast.tree[1].content, "do more");
    expect(ast.tree[1].children.length, 0);
  });

  test('complex expression', () {
    var ast = DirkAST(contents: '''@(do something)
@( do more )''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.expression);
    expect(ast.tree[0].content, "do something");
    expect(ast.tree[0].children.length, 0);

    expect(ast.tree[1].type, TokenType.expression);
    expect(ast.tree[1].content, "do more");
    expect(ast.tree[1].children.length, 0);
  });

  test('expression', () {
    var ast = DirkAST(contents: '''@do something
@more.do()''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.expression);
    expect(ast.tree[0].content, "do");
    expect(ast.tree[0].children.length, 0);

    expect(ast.tree[1].type, TokenType.text);
    expect(ast.tree[1].content, " something ");
    expect(ast.tree[1].children.length, 0);

    expect(ast.tree[2].type, TokenType.expression);
    expect(ast.tree[2].content, "more.do()");
    expect(ast.tree[2].children.length, 0);
  });

  test('plain text', () {
    var ast = DirkAST(contents: '''<h1>Title text</h1>
<p>Paragraph</p>''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.text);
    expect(ast.tree[0].content, "<h1>Title text</h1> <p>Paragraph</p>");
    expect(ast.tree[0].children.length, 0);
  });

  test('mixed markup', () {
    var ast = DirkAST(contents: '''@import some_cool_lib

@model some_cool_model_type

<h1>Title text</h1>
@(Model.execute())
<p>Some text</p>

@{ var m = 1; }

<p>Another text</p>
@for (var i = 1; i < 10; i++ ) {
  do more
  @if (new_cond) {
    nothing to write home about
  }
}

@if(cond) {
  then do something
}

my@@email.com''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$import);
    expect(ast.tree[0].content, "some_cool_lib");

    expect(ast.tree[1].type, TokenType.model);
    expect(ast.tree[1].content, "some_cool_model_type");

    //some whitespaces here and there are ok at moment
    expect(ast.tree[2].type, TokenType.text);
    expect(ast.tree[2].content, " <h1>Title text</h1> ");

    expect(ast.tree[3].type, TokenType.expression);
    expect(ast.tree[3].content, "Model.execute()");

    expect(ast.tree[4].type, TokenType.text);
    expect(ast.tree[4].content, " <p>Some text</p> ");

    expect(ast.tree[5].type, TokenType.block);
    expect(ast.tree[5].content, "var m = 1;");
    expect(ast.tree[5].children.length, 0);

    expect(ast.tree[6].type, TokenType.text);
    expect(ast.tree[6].content, " <p>Another text</p> ");

    expect(ast.tree[7].type, TokenType.$for);
    expect(ast.tree[7].content, "var i = 1; i < 10; i++");
    expect(ast.tree[7].children.length, 2);
    expect(ast.tree[7].children[0].type, TokenType.text);
    expect(ast.tree[7].children[0].content, "do more ");
    expect(ast.tree[7].children[0].children, []);
    expect(ast.tree[7].children[1].type, TokenType.$if);
    expect(ast.tree[7].children[1].content, "new_cond");
    expect(ast.tree[7].children[1].children.length, 1);
    expect(ast.tree[7].children[1].children[0].type, TokenType.text);
    expect(ast.tree[7].children[1].children[0].content,
        "nothing to write home about ");

    expect(ast.tree[8].type, TokenType.$if);
    expect(ast.tree[8].content, "cond");
    expect(ast.tree[8].children.length, 1);
    expect(ast.tree[8].children.first.type, TokenType.text);
    expect(ast.tree[8].children.first.content, "then do something ");
    expect(ast.tree[8].children.first.children, []);

    expect(ast.tree[9].type, TokenType.text);
    expect(ast.tree[9].content, " my@email.com");
  });

  test('mixed markup', () {
    var ast = DirkAST(contents: '''<html>
<body>
    Sparta this is!
    @print('Index Heylo')
</body>
</html>''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.text);
    expect(ast.tree[0].content, "<html> <body> Sparta this is! ");
  });

  test('prepends _start', () {
    var ast = DirkAST(start: '''@import 'dart:math' as math;
@{
  layout = "shared/layout.dirk.dart";
}''', contents: '''<html>
<body>
    Sparta this is!
</body>
</html>''')..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$import);
    expect(ast.tree[0].content, ''''dart:math' as math''');

    expect(ast.tree[1].type, TokenType.block);
    expect(ast.tree[1].content, '''layout = "shared/layout.dirk.dart";''');

    expect(ast.tree[2].type, TokenType.text);
    expect(
        ast.tree[2].content, " <html> <body> Sparta this is! </body> </html>");
  });

  test('uses layout', () {
    var ast = DirkAST(
      layout: '''<html>
<body>
    @renderBody()
</body>
</html>''',
      contents: "Sparta this is!",
    )..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.text);
    expect(
        ast.tree[0].content, "<html> <body> Sparta this is! </body> </html>");
  });

  test('partials being processed', () {
    var ast = DirkAST(
      start: '''@import 'dart:math';''',
      layout: '''<html>
<body>
    @renderBody()
</body>
</html>''',
      contents: "Sparta this is!",
      isPartial: true,
    )..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.text);
    expect(ast.tree[0].content, "Sparta this is!",
        reason: "Partials ignore layout and _start files");
  });

  test('@renderPartial works in any view/layout', () {
    var ast = DirkAST(
      layout: '''
<html>
    @renderPartial("_header")
    <body>
        @renderBody()
    </body>
</html>
    ''',
      contents: '''
<p>Sparta this is!</p>
<p>@renderPartial("_body", 12)</p>
    ''',
    )..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[1].type, TokenType.partial);
    expect(ast.tree[1].content, '"_header"');

    expect(ast.tree[3].type, TokenType.partial);
    expect(ast.tree[3].content, '"_body", 12');
  });
}
