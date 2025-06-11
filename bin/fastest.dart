import 'dart:io';

import 'package:args/args.dart';
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

  final results = parser.parse(args);

  final coverage = results['coverage'] as bool;
  final concurrency =
      results['concurrency'] as bool ? Platform.numberOfProcessors : 1;
  final testPath = results['path'] as String;

  final optimizer = TestOptimizer();

  final runner = TestRunner(
    optimizer,
    coverage: coverage,
    concurrency: concurrency,
    testPath: testPath,
  );

  await runner.execute();
}
