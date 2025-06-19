import 'dart:io';

import 'package:fastest/src/args/args_parser.dart';
import 'package:fastest/src/coverage/coverage_check.dart';
import 'package:fastest/src/optimizer/test_optimizer.dart';
import 'package:fastest/src/output/colored_output.dart';
import 'package:fastest/src/output/console_color.dart';
import 'package:fastest/src/runner/monorepo_runner.dart';
import 'package:fastest/src/runner/test_runner.dart';

void main(List<String> args) async {
  final parser = ArgsParser.instance;

  try {
    await parser(args);
    
    if (parser.coverage) {
      await CoverageCheck.verify(autoConfirm: parser.autoConfirm);
    }

    final runner = switch (parser.isPackage) {
      true => MonorepoRunner(
          rootPath: parser.testPath,
          coverage: parser.coverage,
          concurrency: parser.concurrency,
          failFast: parser.failFast,
        ),
      false => TestRunner(
          TestOptimizer(),
          coverage: parser.coverage,
          concurrency: parser.concurrency,
          testPath: parser.testPath,
          failFast: parser.failFast,
        ),
    };

    await runner.execute();
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
