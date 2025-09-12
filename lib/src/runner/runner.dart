import 'dart:async';

import '../process/process_handler.dart';
import 'monorepo_runner.dart';
import 'test_runner.dart';

/// Interface base para execução de tarefas
abstract class Runner {
  /// Cria uma nova instância de Runner baseada no tipo de projeto
  factory Runner({
    required bool isPackage,
    required String testPath,
    required bool coverage,
    required int concurrency,
    required bool failFast,
    required bool verbose,
    ProcessHandler? processHandler,
  }) {
    final handler = processHandler ?? const DefaultProcessHandler();

    switch (isPackage) {
      case true:
        return MonorepoRunner(
          rootPath: testPath,
          coverage: coverage,
          concurrency: concurrency,
          failFast: failFast,
          verbose: verbose,
          processHandler: handler,
        );
      case false:
        return TestRunner(
          coverage: coverage,
          concurrency: concurrency,
          testPath: testPath,
          failFast: failFast,
          verbose: verbose,
          processHandler: handler,
        );
    }
  }

  /// Executa a tarefa e retorna o código de saída
  Future<int> execute();
}
