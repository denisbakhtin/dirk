// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations.dart';

class DirkViewsGenerator extends GeneratorForAnnotation<DirkViews> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    //print(element);
    var viewsPath = annotation.read("path").stringValue;
    var layoutName = annotation.read("layout").stringValue;
    print(viewsPath);
    print(layoutName);
    //print(buildStep);
    return 'var i = 1;';
  }
}
