// Generated by DirkAST, don't modify

// ignore_for_file: unused_import, unused_local_variable
import 'views.dirk.dart';
import 'dart:math' as math;

String IndexView() {
  String res = '';
  var mathE = math.e;
  res += ''' <html> ''';
  res += '''${PartialHeaderView("Awesome Website")}''';
  res += ''' <body> Sparta this is! ''';
  res += '''${(1 + 1).toString()}''';
  res += ''' Now loop paragraphs ''';
  for (var i = 1; i < 10; i++) {
    res += '''<p>Awesome printing #''';
    res += '''${i}''';
    res += '''</p> ''';
  }
  res += ''' </body> </html>''';
  return res;
}
