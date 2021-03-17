import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

//import 'src/dirk_code_generator.dart';
//import 'src/dirk_export_generator.dart';
import 'src/dirk_views_generator.dart';

Builder viewsBuilder(BuilderOptions options) =>
    SharedPartBuilder([DirkViewsGenerator()], 'views');

/*
//Generates *.dirk.dart based on *.dirk.html
DirkCodeGenerator dirkCodeBuilder(BuilderOptions options) =>
    DirkCodeGenerator(options);

//Generates views.dirk.dark that exports all files above
DirkExportGenerator dirkExportBuilder(BuilderOptions options) =>
    DirkExportGenerator(options);

*/