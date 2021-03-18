import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

import 'dirk_ast.dart';
import 'utility.dart';

const String _outputFileExtension = '.dirk.dart';

class DirkCodeGenerator implements Builder {
  late Map<String, dynamic> _options;
  late String _inputFolder;

  DirkCodeGenerator(BuilderOptions builderOptions) {
    _options = builderOptions.config;
    _inputFolder = p.normalize(_options["input_folder"]);
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dirk.html': ['.dirk.dart']
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final fileNameWithExtension =
        buildStep.inputId.pathSegments.last.replaceAll('-', '_');

    final rawContents = await buildStep.readAsString(buildStep.inputId);
    var funcNamePrefix = "";
    final dirName = p.dirname(buildStep.inputId.path);

    //if the view is nested, apply subfolders to func name as prefix
    if (p.isWithin(_inputFolder, dirName)) {
      funcNamePrefix = p
          .split(dirName)
          .skip(p.split(_inputFolder).length)
          .map((part) => ReCase(part).pascalCase)
          .join('');
    }

    final fileNameWithoutExtension = fileNameWithExtension.split('.').first;
    final viewFuncName =
        fileNameToView(fileNameWithExtension, prefix: funcNamePrefix);

    final ast = DirkAST(
      contents: rawContents,
      isPartial: isPartial(fileNameWithExtension),
    )..parse();
    final result = ast.toViewFunction(viewFuncName);

    final copyAssetId = AssetId(buildStep.inputId.package,
        '${p.dirname(buildStep.inputId.path)}/$fileNameWithoutExtension$_outputFileExtension');

    await buildStep.writeAsString(copyAssetId, result);
  }
}
