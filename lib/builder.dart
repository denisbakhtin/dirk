import 'package:build/build.dart';
import 'src/dirk_code_generator.dart';
import 'src/dirk_views_generator.dart';

//Generates *.dirk.dart based on *.dirk.html
Builder dirkCodeBuilder(BuilderOptions options) => DirkCodeGenerator(options);

//Generates views.dart that combines all the above files
Builder dirkViewsBuilder(BuilderOptions options) => DirkViewsGenerator(options);
