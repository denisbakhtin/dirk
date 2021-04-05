import 'package:string_scanner/string_scanner.dart';
import "package:charcode/ascii.dart";

import 'types.dart';
import 'utility.dart';

final RegExp _whitespace = RegExp(r'[ \n\r\t]+');
final RegExp _whitespaceOnly = RegExp(r'^[ \n\r\t]+$');
final RegExp _at = RegExp(r'@');
final RegExp _import = RegExp(r'import[\s\t]+');
final RegExp _model = RegExp(r'model[\s\t]+');
final RegExp _if = RegExp(r'if[\s\t]*');
final RegExp _ifCondition = RegExp(r'\(([^\n]+)\)[\s\t]*\{[\s\t\n]+');
final RegExp _forCondition = RegExp(r'\(([^\n]+)\)[\s\t]*\{[\s\t\n]+');
final RegExp _for = RegExp(r'for[\s\t]*');
final RegExp _block = RegExp(r'\{');
final RegExp _expr = RegExp(r'([A-Za-z]+[A-Za-z0-9_]*)');
final RegExp _member = RegExp(r'(\.[A-Za-z]+[A-Za-z0-9_]*)');
final RegExp _lparen = RegExp(r'\(');
final RegExp _partial = RegExp(r'renderPartial[\s\t]*');

class DirkAST {
  final String contents;
  final String fileName;
  late final bool _isPartial;
  late final bool _isLayout;
  late final String _funcName;
  List<DirkError> errors = [];
  List<Token> tree = [];

  DirkAST({
    this.contents = '',
    this.fileName = '',
  }) {
    _isPartial = isPartial(fileName);
    _funcName = fileNameToView(fileName);
    _isLayout = _funcName == "LayoutView";
  }

  String _scanTillEndOfStatement(SpanScanner scanner) {
    var buffer = '';
    while (!scanner.isDone) {
      var ch = scanner.readChar();
      if (ch == $cr || ch == $lf || ch == $semicolon) {
        return buffer;
      }
      buffer += String.fromCharCode(ch);
    }
    errors.add(DirkError("Unfinished statement", scanner.lastSpan));
    return buffer;
  }

  String _scanTillClosingCurlyBrace(SpanScanner scanner) {
    var openBraces = 1;
    var buffer = '';
    while (!scanner.isDone) {
      var ch = scanner.readChar();
      if (ch == $lbrace) openBraces++;
      if (ch == $rbrace && --openBraces == 0) {
        return buffer;
      }
      buffer += String.fromCharCode(ch);
    }
    errors.add(DirkError("Unbalanced { found", scanner.lastSpan));
    return buffer;
  }

  String _scanTillClosingParen(SpanScanner scanner) {
    var openParen = 1;
    var buffer = '';
    while (!scanner.isDone) {
      var ch = scanner.readChar();
      if (ch == $lparen) openParen++;
      if (ch == $rparen && --openParen == 0) {
        return buffer;
      }
      buffer += String.fromCharCode(ch);
    }
    errors.add(DirkError("Unbalanced ( found", scanner.lastSpan));
    return buffer;
  }

  //Parse the contents & build the tree
  void parse() {
    _deepParse(tree, contents);
  }

  //parse contents recursively. Note, that tree & contents variables are shadowed
  //for no real purpose, but still
  void _deepParse(List<Token> tree, String contents) {
    SpanScanner _scanner = SpanScanner(contents);

    while (!_scanner.isDone) {
      if (_scanner.scan(_whitespace)) {
        _getOrCreateTextNode(tree).content += " ";
        continue;
      }

      //code block challenger
      if (_scanner.scan(_at)) {
        //@@ is an escaped literal @
        if (_scanner.scan(_at)) {
          _getOrCreateTextNode(tree).content += "@";
          continue;
        }
        //matches: 'import '...'
        if (_scanner.scan(_import)) {
          var text = _scanTillEndOfStatement(_scanner);
          tree.add(Token(TokenType.$import, text));
          continue;
        }
        //matches: 'model ...
        if (_scanner.scan(_model)) {
          var text = _scanTillEndOfStatement(_scanner);
          tree.add(Token(TokenType.model, text));
          continue;
        }
        //matches: if (...) {...}
        if (_scanner.scan(_if)) {
          if (_scanner.scan(_ifCondition)) {
            var condition = _scanner.lastMatch?.group(1);
            var body = _scanTillClosingCurlyBrace(_scanner);
            tree.add(Token(TokenType.$if, condition ?? ""));
            _deepParse(tree.last.children, body);
          } else {
            errors.add(DirkError(
                "Incorrect 'if' condition pattern", _scanner.lastSpan));
          }
          continue;
        }
        //matches: for(...) {...}
        if (_scanner.scan(_for)) {
          if (_scanner.scan(_forCondition)) {
            var condition = _scanner.lastMatch?.group(1);
            var body = _scanTillClosingCurlyBrace(_scanner);
            tree.add(Token(TokenType.$for, condition ?? ""));
            _deepParse(tree.last.children, body);
          } else {
            errors.add(DirkError(
                "Incorrect 'for' condition pattern", _scanner.lastSpan));
          }
          continue;
        }
        //matches: renderPartial(...)
        if (_scanner.scan(_partial)) {
          if (_scanner.scan(_lparen)) {
            var body = _scanTillClosingParen(_scanner);
            tree.add(Token(TokenType.partial, body));
          } else {
            errors.add(DirkError("Incorrect 'renderPartial' parameters pattern",
                _scanner.lastSpan));
          }
          continue;
        }
        //matches: {...}
        if (_scanner.scan(_block)) {
          var body = _scanTillClosingCurlyBrace(_scanner);
          tree.add(Token(TokenType.block, body));
          continue;
        }
        //matches: (...)
        if (_scanner.scan(_lparen)) {
          var body = _scanTillClosingParen(_scanner);
          tree.add(Token(TokenType.expression, body));
          continue;
        }
        //matches: anyExpression
        if (_scanner.scan(_expr)) {
          var body = _scanner.lastMatch?.group(1);
          tree.add(Token(TokenType.expression, body ?? ""));
          while (!_scanner.isDone) {
            //.member match
            if (_scanner.scan(_member)) {
              tree.last.content += _scanner.lastMatch?.group(1) ?? "";
              continue;
            }
            //( match
            if (_scanner.scan(_lparen)) {
              var params = _scanTillClosingParen(_scanner);
              tree.last.content += "($params)";
              continue;
            }
            break;
          }
          continue;
        }
        errors.add(DirkError("Unknown @ sequence", _scanner.lastSpan));
        continue;
      }

      //else raw text
      _getOrCreateTextNode(tree).content +=
          String.fromCharCode(_scanner.readChar());
    }
    _trimTree(tree);
  }

  //returns the current text node or creates a new one
  Token _getOrCreateTextNode(List<Token> tree) {
    if (tree.length == 0 || tree.last.type != TokenType.text)
      tree.add(Token(TokenType.text, ""));
    return tree.last;
  }

  _trimTree(List<Token> tree) {
    //remove leaves consisting only of whitespaces
    tree.removeWhere((el) =>
        el.type == TokenType.text && _whitespaceOnly.hasMatch(el.content));
    tree
        .where((el) => el.type != TokenType.text)
        .forEach((el) => el.content = el.content.trim());
  }

  //Compile the tree as a view function
  String toViewFunction() {
    StringBuffer result = StringBuffer();
    List<Token> imports =
        tree.where((el) => el.type == TokenType.$import).toList();
    Token model = tree.firstWhere((el) => el.type == TokenType.model,
        orElse: () => Token(TokenType.model, ""));
    tree.removeWhere(
        (el) => el.type == TokenType.$import || el.type == TokenType.model);

    //force String param for LayoutView
    String modelType = _isLayout ? "String" : model.content;

    imports.forEach((el) => result.writeln(el));
    result.writeln("import 'package:dirk/sanitize.dart';");
    if (modelType != '') {
      result.writeln(
          "String ${_funcName}($modelType model, {Map<String, dynamic> viewData = const {}}) {");
    } else {
      result.writeln(
          "String ${_funcName}({Map<String, dynamic> viewData = const {}}) {");
    }
    //reserved variables
    result.writeln("String res = '';");
    //create a local copy of viewData map
    result.writeln("viewData = Map.from(viewData);");
    //TBD, atm layout is fixed
    //you can override 'layout' var in the _viewstart or a specific view
    //result.writeln("String layout = '';");

    tree.forEach((el) => result.writeln(el));

    result.writeln(_isLayout || _isPartial
        ? "return res;"
        : "return LayoutView(res, viewData: viewData);");
    result.writeln("}");

    //for LayoutView replace placeholder with model param
    var res = _isLayout
        ? result
            .toString()
            .replaceAll(RegExp(r'sanitize\(renderBody\(\)\)'), 'model')
        : result.toString();

    return tryFormatCode(res);
  }

  printErrors() {
    errors.forEach((err) {
      print('''[WARNING] Code parsing failed.
          Reason: $err
          ''');
    });
  }
}
