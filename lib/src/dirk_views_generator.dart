import 'package:build/build.dart';
import 'package:dirk/src/utility.dart';
import 'package:glob/glob.dart';

class DirkViewsGenerator implements Builder {
  late Map<String, dynamic> _options;
  late String _outputName;

  DirkViewsGenerator(BuilderOptions builderOptions) {
    _options = builderOptions.config;
    _outputName = "${_options["output_file"]}";
  }

  AssetId _viewsFileOutput(BuildStep buildStep) {
    return AssetId(buildStep.inputId.package, _outputName);
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      r'lib/$lib$': [_outputName]
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final views = <String>[];
    final Set imports = {};
    final importRe = RegExp(r'import[\s\t]+[^\n]*;\n');
    final layoutRe = RegExp(r'String LayoutView\([^\n]*\{\n');

    await for (final input in buildStep.findAssets(Glob('**.dirk.dart'))) {
      var rawContents = await buildStep.readAsString(input);
      //we move all import statements to the start of the output
      imports.addAll(importRe.allMatches(rawContents).map((e) => e.group(0)));
      rawContents = rawContents.replaceAll(importRe, '');

      views.add(rawContents);
    }

    final output = _viewsFileOutput(buildStep);
    var outputContents = views.join('\n');

    //Add simple layout function if not present (ex: no _layout.dirk.html file)
    if (!layoutRe.hasMatch(outputContents)) {
      outputContents += emptyLayoutFunction();
    }

    outputContents = '''
// Generated by Dirk Generator, don't modify by hand

// ignore_for_file: unused_import, unused_local_variable
${imports.join("\n")}

$outputContents
''';
    outputContents = tryFormatCode(outputContents);

    return buildStep.writeAsString(output, outputContents);
  }
}
