import 'package:dirk/src/utility.dart';
import 'package:source_span/source_span.dart';

enum TokenType {
  layout,
  $import,
  type,
  $if,
  $for,
  block,
  expression,
  text,
  partial,
}

class Token {
  TokenType type;
  String content;
  List<Token> children;
  //used for storing 'else' part of 'if' statement atm
  List<Token> childrenAlt;
  final bool sanitize;
  Token(this.type, this.content,
      {this.sanitize = true,
      this.children = const [],
      this.childrenAlt = const []}) {
    children = List<Token>.from(children, growable: true);
    childrenAlt = List<Token>.from(childrenAlt, growable: true);
  }

  @override
  String toString() {
    switch (type) {
      case TokenType.$import:
        return "import $content;";
      case TokenType.text:
        return "res += '''$content''';";
      case TokenType.$if:
        {
          var result = "if ($content) {\n";
          children.forEach((el) => result += el.toString());
          result += "}";
          if (childrenAlt.isNotEmpty) {
            result += " else {\n";
            childrenAlt.forEach((el) => result += el.toString());
            result += "}";
          }

          return result;
        }
      case TokenType.$for:
        {
          var result = "for ($content) {\n";
          children.forEach((el) => result += el.toString());
          result += "}";
          return result;
        }
      case TokenType.block:
        return content;
      case TokenType.expression:
        return "res += '''\${sanitize($content)}''';";
      case TokenType.partial:
        {
          var parts = content.split(",");
          if (parts.length > 2)
            throw DirkException(
                "Wrong renderPartial parameters, max 2 are allowed");
          final RegExp rPartialName = RegExp('''['"]([_A-Za-z0-9\\/]+)['"]''');
          if (!rPartialName.hasMatch(parts.first))
            throw DirkException(
                "Wrong partial name. Must be an alpha-numeric string in quotes");
          var name = rPartialName.firstMatch(parts.first)?.group(1);
          var result = "res += '''\${";
          result += fileNameToView(name ?? "");
          result += parts.length > 1
              ? '(${parts.last.trim()}, viewData: viewData)'
              : '(viewData: viewData)';
          result += "}''';";
          return result;
        }
      default:
        return "";
    }
  }
}

class DirkException {
  final String message;

  DirkException(this.message);

  @override
  String toString() {
    return 'exception: $message\n';
  }
}

class DirkError extends Error {
  final String message;
  final FileSpan? span;

  DirkError(this.message, this.span);

  @override
  String toString() {
    return 'error: ${span?.start.toolString}: $message\n' +
        (span?.highlight(color: true) ?? "");
  }
}
