import 'package:build/build.dart';

import 'src/dirk_code_generator.dart';
import 'src/dirk_export_generator.dart';

DirkCodeGenerator dirkCodeBuilder(BuilderOptions options) =>
    DirkCodeGenerator(options);

DirkExportGenerator dirkExportBuilder(BuilderOptions options) =>
    DirkExportGenerator(options);
