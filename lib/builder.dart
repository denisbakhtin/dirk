import 'package:build/build.dart';
import 'src/dirk_code_generator.dart';
import 'src/dirk_views_generator.dart';

//Generates *.dirk.dart based on *.dirk.html
Builder dirkCodeBuilder(BuilderOptions options) => DirkCodeGenerator(options);

//Generates views.dart that exports all files above
Builder dirkViewsBuilder(BuilderOptions options) => DirkViewsGenerator(options);
