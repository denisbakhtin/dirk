import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart';

import 'dirk_ast.dart';
import 'utility.dart';

const String _inputFileExtension = '.dirk.html';
const String _outputFileExtension = '.dirk.dart';

Map<String, List<String>> generateExtensions(Map<String, dynamic> options) {
  final filesList = Directory(options['input_folder'])
      .listSync(recursive: true)
      .where(
          (FileSystemEntity file) => file.path.endsWith(_inputFileExtension));

  final result = <String, List<String>>{};

  filesList.forEach((FileSystemEntity element) {
    final name = split(element.path).last.split('.').first.replaceAll('-', '_');
    result[element.path] = <String>[
      '${options["output_folder"]}$name$_outputFileExtension',
    ];
  });

  print(result);
  return result;
}

class DirkCodeGenerator implements Builder {
  String _start;
  String _layout;
  Map<String, dynamic> _options;
  Map<String, List<String>> _buildExtensionsCopy;
  List<String> _ignoreFiles;

  DirkCodeGenerator(BuilderOptions builderOptions) {
    _options = builderOptions.config;
    _start = File('${_options["input_folder"]}${_options["start_file"]}')
        ?.readAsStringSync();
    _layout = File('${_options["input_folder"]}${_options["layout_file"]}')
        ?.readAsStringSync();
    _ignoreFiles = [_options["start_file"], _options["layout_file"]];
  }

  @override
  Map<String, List<String>> get buildExtensions =>
      _buildExtensionsCopy ??= generateExtensions(_options);

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
        '${_options["output_folder"]}$fileNameWithoutExtension$_outputFileExtension');

    await buildStep.writeAsString(copyAssetId, result);
  }
}
