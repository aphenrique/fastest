import 'dart:io';

import 'package:fastest/src/args_parser.dart';
import 'package:fastest/src/colored_output.dart';
import 'package:fastest/src/console_color.dart';
import 'package:fastest/src/coverage_check.dart';
import 'package:fastest/src/test_optimizer.dart';
import 'package:fastest/src/test_runner.dart';

void main(List<String> args) async {
  final parser = ArgsParser();

  try {
    final results = await parser(args);
    final rest = results.rest;

    final coverage = results['coverage'] as bool;

    if (coverage) {
      await CoverageCheck.verify();
    }

    final concurrency =
        results['concurrency'] as bool ? Platform.numberOfProcessors : 1;

    // Se houver um argumento posicional, usa ele como caminho
    // Caso contrário, usa o valor da opção --path
    final testPath = rest.isNotEmpty ? rest.first : results['path'] as String;

    final optimizer = TestOptimizer();

    final runner = TestRunner(
      optimizer,
      coverage: coverage,
      concurrency: concurrency,
      testPath: testPath,
    );

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
