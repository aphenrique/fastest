import 'dart:io';

import 'package:fastest/src/args/args_parser.dart';
import 'package:fastest/src/coverage/coverage_check.dart';
import 'package:fastest/src/output/colored_output.dart';
import 'package:fastest/src/output/console_color.dart';
import 'package:fastest/src/runner/runner.dart';

void main(List<String> args) async {
  final parser = ArgsParser.instance;

  try {
    await parser(args);

    if (parser.coverage) {
      await CoverageCheck.verify(autoConfirm: parser.autoConfirm);
    }

    final runner = Runner(
      isPackage: parser.isPackage,
      testPath: parser.testPath,
      coverage: parser.coverage,
      concurrency: parser.concurrency,
      failFast: parser.failFast,
      verbose: parser.verbose,
    );

    final exitCode = await runner.execute();

    exit(exitCode);
  } catch (e) {
    ColoredOutput.writeln(ConsoleColor.red, 'Erro ao executar o comando:');
    ColoredOutput.writeln(ConsoleColor.red, e.toString());
    ColoredOutput.writeln(
      ConsoleColor.red,
      '\nUso: fastest [pasta_dos_testes] [opções]',
    );
    ColoredOutput.writeln(ConsoleColor.red, parser.usage);
    exit(1);
  }
}
