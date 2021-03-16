import 'package:dirk/src/utility.dart';

import 'package:test/test.dart';

void main() {
  test('isPartial', () {
    expect(isPartial("_header"), true);
    expect(isPartial("header"), false);
  });

  //model type is not to be tested
  test('fileNameToView', () {
    expect(fileNameToView("_header.dirk.html"), "PartialHeaderView");
    expect(fileNameToView("header.dirk.html"), "HeaderView");
  });
}
