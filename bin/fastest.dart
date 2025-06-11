import 'dart:io';

import 'package:args/args.dart';
import 'package:fastest/src/colored_output.dart';
import 'package:fastest/src/console_color.dart';
import 'package:fastest/src/test_optimizer.dart';
import 'package:fastest/src/test_runner.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'coverage',
      negatable: false,
      help: 'Habilita a coleta de cobertura de código',
    )
    ..addFlag(
      'concurrency',
      negatable: false,
      help: 'Habilita execução concorrente dos testes',
    )
    ..addOption(
      'path',
      defaultsTo: Directory.current.path,
      help:
          'Caminho da pasta de testes (opcional, usa pasta atual se não informado)',
      valueHelp: 'path',
    );

  try {
    final results = parser.parse(args);
    final rest = results.rest;

    final coverage = results['coverage'] as bool;
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
