import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as p;

import 'dirk_ast.dart';
import 'utility.dart';

const String _outputFileExtension = '.dirk.dart';

class DirkCodeGenerator implements Builder {
  String _start;
  String _layout;
  Map<String, dynamic> _options;
  List<String> _ignoreFiles;

  DirkCodeGenerator(BuilderOptions builderOptions) {
    _options = builderOptions.config;
    print("OPTIONS: $_options");
    _start = File('${_options["input_folder"]}${_options["start_file"]}')
        ?.readAsStringSync();
    _layout = File('${_options["input_folder"]}${_options["layout_file"]}')
        ?.readAsStringSync();
    _ignoreFiles = [_options["start_file"], _options["layout_file"]];
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dirk.html': ['.dirk.dart']
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    print(buildStep.inputId);
    final fileNameWithExtension =
        buildStep.inputId.pathSegments.last.replaceAll('-', '_');

    if (_ignoreFiles.contains(fileNameWithExtension)) return;

    final rawContents = await buildStep.readAsString(buildStep.inputId);
    final fileNameWithoutExtension = fileNameWithExtension.split('.').first;
    final viewFuncName = fileNameToView(fileNameWithExtension);

    final ast = DirkAST(
      start: _start,
      layout: _layout,
      contents: rawContents,
      isPartial: isPartial(fileNameWithExtension),
    )..parse();
    final result = ast.toViewFunction(viewFuncName);

    final copyAssetId = AssetId(buildStep.inputId.package,
        '${p.dirname(buildStep.inputId.path)}/$fileNameWithoutExtension$_outputFileExtension');

    await buildStep.writeAsString(copyAssetId, result);
  }
}
