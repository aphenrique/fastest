import 'dart:async';
import 'dart:collection';

import '../../process/process_handler.dart';
import '../../view/colored_output.dart';
import '../../view/console_color.dart';
import '../../view/test_output.dart';
import '../package/monorepo_package.dart';
import '../test_runner.dart';

/// Classe responsável por executar testes em paralelo em um ambiente monorepo
class MonorepoExecutor {
  MonorepoExecutor({
    required this.packages,
    required this.concurrency,
    this.coverage = false,
    this.failFast = false,
    this.verbose = false,
    ProcessHandler? processHandler,
  }) : _processHandler = processHandler {
    _totalPackages = packages.length;
  }

  final List<MonorepoPackage> packages;
  final int concurrency;
  final bool coverage;
  final bool failFast;
  final bool verbose;
  final ProcessHandler? _processHandler;
  late final int _totalPackages;
  var _currentPackage = 0;

  /// Executa os testes em paralelo para todos os pacotes
  Future<int> execute() async {
    if (packages.isEmpty) return 0;

    ColoredOutput.writeln(
      ConsoleColor.cyan,
      'Encontrados ${packages.length} pacotes com testes:',
    );

    // Lista os pacotes encontrados
    for (final package in packages) {
      ColoredOutput.writeln(
        ConsoleColor.yellow,
        '  - ${package.name}',
      );
    }

    ColoredOutput.writeln(
      ConsoleColor.cyan,
      '\nIniciando execução dos testes...\n',
    );

    final queue = Queue<MonorepoPackage>.from(packages);
    final running = Queue<Future<int>>();
    var hasFailures = false;

    while (queue.isNotEmpty || running.isNotEmpty) {
      // Preenche o pool até o máximo permitido pelo concurrency
      while (queue.isNotEmpty && running.length < concurrency) {
        final package = queue.removeFirst();
        _currentPackage++;

        try {
          final testOutput = TestOutput(
            verbose,
            packageName: package.name,
            failFast: failFast,
            isMonorepo: true,
            totalPackages: _totalPackages,
            currentPackage: _currentPackage,
          );

          final runner = TestRunner(
            testPath: package.path,
            coverage: coverage,
            concurrency: concurrency,
            failFast: failFast,
            verbose: verbose,
            processHandler: _processHandler,
            testOutput: testOutput,
          );

          final future = runner.execute().catchError((error) {
            hasFailures = true;
            ColoredOutput.writeln(
              ConsoleColor.red,
              'Falha ao executar testes em: ${package.path}',
            );
            return 2;
          });

          running.add(future);
        } catch (e) {
          hasFailures = true;
          ColoredOutput.writeln(
            ConsoleColor.red,
            'Falha ao executar testes em: ${package.path}',
          );
        }
      }

      // Espera pelo menos um dos testes completar antes de continuar
      if (running.isNotEmpty) {
        final results = await Future.wait([running.removeFirst()]);
        if (failFast && results.any((code) => code != 0)) {
          return 9;
        }
      }
    }

    return hasFailures ? 1 : 0;
  }
}
