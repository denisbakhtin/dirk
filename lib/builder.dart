import 'package:build/build.dart';

import 'src/dirk_code_generator.dart';
import 'src/dirk_export_generator.dart';

//Generates *.dirk.dart based on *.dirk.html
DirkCodeGenerator dirkCodeBuilder(BuilderOptions options) =>
    DirkCodeGenerator(options);

//Generates views.dirk.dark that exports all files above
DirkExportGenerator dirkExportBuilder(BuilderOptions options) =>
    DirkExportGenerator(options);
