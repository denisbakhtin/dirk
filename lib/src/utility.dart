import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';

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
//index.dirk.dart -> IndexView
//_header.dirk.dart -> PartialHeaderView
//Works for file name even without extention
//prefix should be already in PascalCase
String fileNameToView(String name, {String prefix = ''}) {
  final nameWithoutExtension = name.split('.').first;
  return (isPartial(name) ? "Partial" : "") +
      prefix +
      ReCase(nameWithoutExtension).pascalCase +
      "View";
}

//checks if file name designates a partial view
bool isPartial(String name) {
  return name.startsWith("_");
}

String emptyLayoutFunction() => '''
String LayoutView(String model) {
  return model;
}
''';
