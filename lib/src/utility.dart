import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';
import 'package:path/path.dart' as p;

String tryFormatCode(String code) {
  try {
    final formattedResult = DartFormatter().format(code);
    return formattedResult;
  } catch (e) {
    print('''[WARNING] Code formatting failed.
          Please raise an issue on https://github.com/denisbakhtin/dirk/issues/
          Reason: $e''');
    return code;
  }
}

//transforms a file name into a view name, ex:
//index.dirk.html -> IndexView
//shared/menu.dirk.html -> SharedMenuView
//_header.dirk.html -> PartialHeaderView
//shared/_header.dirk.html -> PartialSharedHeaderView
String fileNameToView(String name) {
  try {
    var parts = p.split(name);
    //remove extension
    parts.last = parts.last.split('.').first;
    var isPartialFile = isPartial(name);
    return (isPartialFile ? "Partial" : "") +
        parts.map((el) => ReCase(el).pascalCase).join('') +
        "View";
  } catch (e) {
    print('''[Error] in fileNameToView.
          Reason: $e''');
    return "_";
  }
}

//checks if file name designates a partial view
bool isPartial(String name) {
  try {
    return p.split(name).last.startsWith("_");
  } catch (_) {
    return false;
  }
}

String emptyLayoutFunction() => '''
String LayoutView(String model) {
  return model;
}
''';
