// Ensure that the build script itself is not opted in to null safety,
// instead of taking the language version from the current package.
//
// @dart=2.9
//
// ignore_for_file: directives_ordering

import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:dirk/builder.dart' as _i2;
import 'package:build_config/build_config.dart' as _i3;
import 'package:build/build.dart' as _i4;
import 'dart:isolate' as _i5;
import 'package:build_runner/build_runner.dart' as _i6;
import 'dart:io' as _i7;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(r'dirk:dirk_code_builder', [_i2.dirkCodeBuilder],
      _i1.toDependentsOf(r'dirk'),
      hideOutput: false,
      defaultGenerateFor: const _i3.InputSet(include: [r'lib/views/**']),
      defaultOptions: _i4.BuilderOptions({
        'start_file': '_start.dirk.html',
        'layout_file': 'layout.dirk.html'
      })),
  _i1.apply(r'dirk:dirk_export_builder', [_i2.dirkExportBuilder],
      _i1.toDependentsOf(r'dirk'),
      hideOutput: false,
      defaultGenerateFor: const _i3.InputSet(include: [r'lib/views/**']),
      defaultOptions: _i4.BuilderOptions({
        'output_folder': 'lib/views/code/',
        'export_file': 'views.dirk.dart'
      }))
];
void main(List<String> args, [_i5.SendPort sendPort]) async {
  var result = await _i6.run(args, _builders);
  sendPort?.send(result);
  _i7.exitCode = result;
}
