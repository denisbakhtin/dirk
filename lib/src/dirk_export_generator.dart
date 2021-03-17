import 'package:build/build.dart';
import 'package:path/path.dart';
import 'package:glob/glob.dart';

class DirkExportGenerator implements Builder {
  late Glob _allGeneratedViews;
  late Map<String, dynamic> _options;

  DirkExportGenerator(BuilderOptions builderOptions) {
    _options = builderOptions.config;
    _allGeneratedViews = Glob('${_options["output_folder"]}**');
  }

  AssetId _viewsFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      join(_options["output_folder"], _options["export_file"]),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      r'lib/$lib$': [join(_options["output_folder"], _options["export_file"])],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final files = <String>[];
    await for (final input in buildStep.findAssets(_allGeneratedViews)) {
      files.add(input.path);
    }
    final output = _viewsFileOutput(buildStep);
    return buildStep.writeAsString(output,
        files.map((name) => 'export "${split(name).last}";').join('\n'));
  }
}
