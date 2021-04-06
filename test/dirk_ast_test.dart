import 'package:dirk/src/dirk_ast.dart';
import 'package:dirk/src/types.dart';

import 'package:test/test.dart';

void main() {
  test('import', () {
    var ast = DirkAST(contents: '''@import some_cool_lib
@import    another_cool_lib;''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$import);
    expect(ast.tree[0].content, "some_cool_lib");

    expect(ast.tree[1].type, TokenType.$import);
    expect(ast.tree[1].content, "another_cool_lib");
  });

  test('model', () {
    var ast = DirkAST(contents: '''@model some_cool_model_type
@model    another_cool_model_type;''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.model);
    expect(ast.tree[0].content, "some_cool_model_type");

    expect(ast.tree[1].type, TokenType.model);
    expect(ast.tree[1].content, "another_cool_model_type");
  });

  test('if statement', () {
    var ast = DirkAST(contents: '''@if(cond) {
  then do something
}
@if (cond2 ) {
  then do
}
@if (cond3) {hello}''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$if);
    expect(ast.tree[0].content, "cond");
    expect(ast.tree[0].children.length, 1);
    expect(ast.tree[0].children.first.type, TokenType.text);
    expect(ast.tree[0].children.first.content.trim(), "then do something");

    expect(ast.tree[1].type, TokenType.$if);
    expect(ast.tree[1].content, "cond2");
    expect(ast.tree[1].children.length, 1);
    expect(ast.tree[1].children.first.type, TokenType.text);
    expect(ast.tree[1].children.first.content.trim(), "then do");

    expect(ast.tree[2].type, TokenType.$if);
    expect(ast.tree[2].content, "cond3");
    expect(ast.tree[2].children.length, 1);
    expect(ast.tree[2].children.first.type, TokenType.text);
    expect(ast.tree[2].children.first.content.trim(), "hello");
  });

  test('if statement with else', () {
    var ast = DirkAST(contents: '''@if(cond) {
  then do something
} else {
  then do else
}
''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$if);
    expect(ast.tree[0].content, "cond");
    expect(ast.tree[0].children.length, 1);
    expect(ast.tree[0].children.first.type, TokenType.text);
    expect(ast.tree[0].children.first.content.trim(), "then do something");
    expect(ast.tree[0].childrenAlt.length, 1);
    expect(ast.tree[0].childrenAlt.first.type, TokenType.text);
    expect(ast.tree[0].childrenAlt.first.content.trim(), "then do else");
  });

  test('for statement', () {
    var ast = DirkAST(contents: '''@for(cond) {
  do something
}
@for (var i = 1; i < 10; i++ ) {
  do more
}''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$for);
    expect(ast.tree[0].content, "cond");
    expect(ast.tree[0].children.length, 1);
    expect(ast.tree[0].children.first.type, TokenType.text);
    expect(ast.tree[0].children.first.content.trim(), "do something");

    expect(ast.tree[1].type, TokenType.$for);
    expect(ast.tree[1].content, "var i = 1; i < 10; i++");
    expect(ast.tree[1].children.length, 1);
    expect(ast.tree[1].children.first.type, TokenType.text);
    expect(ast.tree[1].children.first.content.trim(), "do more");
  });

  test('block statement', () {
    var ast = DirkAST(contents: '''@{
  do something
}
@{ do more }''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.block);
    expect(ast.tree[0].content.trim(), "do something");

    expect(ast.tree[1].type, TokenType.block);
    expect(ast.tree[1].content.trim(), "do more");
  });

  test('complex expression', () {
    var ast = DirkAST(contents: '''@(do something)
@( do more )''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.expression);
    expect(ast.tree[0].content.trim(), "do something");

    expect(ast.tree[1].type, TokenType.expression);
    expect(ast.tree[1].content.trim(), "do more");
  });

  test('expression', () {
    var ast = DirkAST(contents: '''@do something
@more.do()''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.expression);
    expect(ast.tree[0].content, "do");

    expect(ast.tree[1].type, TokenType.text);
    expect(ast.tree[1].content.trim(), "something");

    expect(ast.tree[2].type, TokenType.expression);
    expect(ast.tree[2].content, "more.do()");
  });

  test('plain text', () {
    var ast = DirkAST(contents: '''<h1>Title text</h1>
<p>Paragraph</p>''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.text);
    expect(ast.tree[0].content, "<h1>Title text</h1> <p>Paragraph</p>");
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

my@@email.com''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.$import);
    expect(ast.tree[0].content, "some_cool_lib");

    expect(ast.tree[1].type, TokenType.model);
    expect(ast.tree[1].content, "some_cool_model_type");

    //some whitespaces here and there are ok at moment
    expect(ast.tree[2].type, TokenType.text);
    expect(ast.tree[2].content.trim(), "<h1>Title text</h1>");

    expect(ast.tree[3].type, TokenType.expression);
    expect(ast.tree[3].content, "Model.execute()");

    expect(ast.tree[4].type, TokenType.text);
    expect(ast.tree[4].content.trim(), "<p>Some text</p>");

    expect(ast.tree[5].type, TokenType.block);
    expect(ast.tree[5].content, "var m = 1;");
    expect(ast.tree[5].children.length, 0);

    expect(ast.tree[6].type, TokenType.text);
    expect(ast.tree[6].content.trim(), "<p>Another text</p>");

    expect(ast.tree[7].type, TokenType.$for);
    expect(ast.tree[7].content, "var i = 1; i < 10; i++");
    expect(ast.tree[7].children.length, 2);
    expect(ast.tree[7].children[0].type, TokenType.text);
    expect(ast.tree[7].children[0].content.trim(), "do more");
    expect(ast.tree[7].children[1].type, TokenType.$if);
    expect(ast.tree[7].children[1].content, "new_cond");
    expect(ast.tree[7].children[1].children.length, 1);
    expect(ast.tree[7].children[1].children[0].type, TokenType.text);
    expect(ast.tree[7].children[1].children[0].content.trim(),
        "nothing to write home about");

    expect(ast.tree[8].type, TokenType.$if);
    expect(ast.tree[8].content, "cond");
    expect(ast.tree[8].children.length, 1);
    expect(ast.tree[8].children.first.type, TokenType.text);
    expect(ast.tree[8].children.first.content.trim(), "then do something");

    expect(ast.tree[9].type, TokenType.text);
    expect(ast.tree[9].content, " my@email.com");
  });

  test('mixed markup', () {
    var ast = DirkAST(contents: '''<html>
<body>
    Sparta this is!
    @print('Index Heylo')
</body>
</html>''', fileName: "index")..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[0].type, TokenType.text);
    expect(ast.tree[0].content.trim(), "<html> <body> Sparta this is!");
  });

  test('@renderPartial works in any view/layout', () {
    var ast = DirkAST(
      contents: '''
<p>Sparta this is!</p>
<p>@renderPartial("_body", 12)</p>
    ''',
      fileName: "index",
    )..parse();

    expect(ast.errors.length, 0);
    expect(ast.tree[1].type, TokenType.partial);
    expect(ast.tree[1].content, '"_body", 12');
  });

  test('generates View function', () {
    var ast = DirkAST(
      contents: '''<html>
<body>
    Best text
</body>
</html>''',
      fileName: "index.dirk.html",
    )..parse();

    expect(ast.errors.length, 0);

    var vfunc = ast.toViewFunction();
    expect(ast.errors.length, 0);
    expect(
        RegExp(r'String IndexView\(\{Map<String, dynamic> viewData = const \{\}\}\) \{')
            .hasMatch(vfunc),
        true,
        reason: vfunc);
  });

  test('generates View function with parameter', () {
    var ast = DirkAST(
      contents: '''@model int;
<html>
  <body>
      Best text
  </body>
</html>''',
      fileName: "index.dirk.html",
    )..parse();

    expect(ast.errors.length, 0);

    var vfunc = ast.toViewFunction();
    expect(ast.errors.length, 0);
    expect(
        RegExp(r'String IndexView\(int model, \{Map<String, dynamic> viewData = const \{\}\}\) \{')
            .hasMatch(vfunc),
        true,
        reason: vfunc);
  });

  test('View function wraps result with layout', () {
    var ast = DirkAST(
      contents: '''<html>
  <body>
      Best text
  </body>
</html>''',
      fileName: "index.dirk.html",
    )..parse();

    expect(ast.errors.length, 0);

    var vfunc = ast.toViewFunction();
    expect(ast.errors.length, 0);
    expect(
        RegExp(r'return LayoutView\(res, viewData: viewData\);')
            .hasMatch(vfunc),
        true,
        reason: vfunc);
  });

  test('LayoutView function does not wrap result with layout', () {
    var ast = DirkAST(
      contents: '''<html>
  <body>
      Best text
  </body>
</html>''',
      fileName: "layout.dirk.html",
    )..parse();

    expect(ast.errors.length, 0);

    var vfunc = ast.toViewFunction();
    expect(ast.errors.length, 0);
    expect(RegExp(r'return res;').hasMatch(vfunc), true, reason: vfunc);
  });

  test('Partial view function does not wrap result with layout', () {
    var ast = DirkAST(
      contents: '''<html>
  <body>
      Best text
  </body>
</html>''',
      fileName: "_header.dirk.html",
    )..parse();

    expect(ast.errors.length, 0);

    var vfunc = ast.toViewFunction();
    expect(ast.errors.length, 0);
    expect(RegExp(r'return res;').hasMatch(vfunc), true, reason: vfunc);
  });

  test('unbalanced closing }', () {
    var ast = DirkAST(contents: '''@if cond) {
  then do something
}''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@if (cond {
  then do something
}''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@if (cond) 
  then do something
}''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@if (cond) {
  then do something
''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@for cond) {
  then do something
}''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@for (cond {
  then do something
}''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@for (cond) 
  then do something
}''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@for (cond) {
  then do something
''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@for (cond) {
  then do something
}''', fileName: "index")..parse();
    expect(ast.errors.length, 0);
  });

  test('unbalanced closing )', () {
    var ast = DirkAST(contents: '''@some(''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@(some''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@obj.method(''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@obj.method()''', fileName: "index")..parse();
    expect(ast.errors.length, 0);
  });

  test('unfinished statements', () {
    var ast = DirkAST(contents: '''@import ''', fileName: "index")..parse();
    expect(ast.errors.length, 1);

    ast = DirkAST(contents: '''@model ''', fileName: "index")..parse();
    expect(ast.errors.length, 1);
  });

  test('expressions are sanitized', () {
    //Stop XSS exploits in the World Wide Web!!
    var ast = DirkAST(
      contents: '''
    @{
      var s = '<a href="javascript:alert();">evil link</a>';
    }
    @s
''',
      fileName: "index",
    )..parse();
    expect(ast.errors.length, 0);
  });
}
