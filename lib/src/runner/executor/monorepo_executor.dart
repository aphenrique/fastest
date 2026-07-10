import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import '../../domain/test_result.dart';
import '../../presentation/result_reporter.dart';
import '../../process/process_handler.dart';
import '../package/monorepo_package.dart';
import '../test_runner.dart';

/// Executa testes em paralelo em um ambiente monorepo.
///
/// Cada pacote roda em um isolate isolado e devolve um [PackageResult]; a
/// renderização (progresso, tabela e falhas) fica a cargo do [ResultReporter].
class MonorepoExecutor {
  MonorepoExecutor({
    required this.packages,
    required this.concurrency,
    this.coverage = false,
    this.failFast = false,
    this.verbose = false,
    ProcessHandler? processHandler,
    ResultReporter reporter = const ResultReporter(),
  })  : _processHandler = processHandler,
        _reporter = reporter {
    _totalPackages = packages.length;
  }

  final List<MonorepoPackage> packages;
  final int concurrency;
  final bool coverage;
  final bool failFast;
  final bool verbose;
  final ProcessHandler? _processHandler;
  final ResultReporter _reporter;
  late final int _totalPackages;

  /// Executa os testes em paralelo para todos os pacotes.
  Future<int> execute() async {
    if (packages.isEmpty) return 0;

    _reporter.announcePackages([for (final p in packages) p.name]);

    final queue = Queue<MonorepoPackage>.from(packages);
    final active = <Future<void>>[];
    final results = <PackageResult>[];
    var completed = 0;
    var shouldStop = false;

    Future<void> runOne(MonorepoPackage package) async {
      final runner = TestRunner(
        testPath: package.path,
        coverage: coverage,
        concurrency: concurrency,
        failFast: failFast,
        verbose: verbose,
        processHandler: _processHandler,
      );

      PackageResult result;
      try {
        result = await Isolate.run(() => runner.run());
      } catch (error) {
        result = PackageResult(
          packageName: package.name,
          success: false,
          exitCode: 1,
          errorLines: ['Falha ao executar testes: $error'],
        );
      }

      completed++;
      results.add(result);
      _reporter.reportProgress(
        current: completed,
        total: _totalPackages,
        result: result,
      );

      if (failFast && !result.success) shouldStop = true;
    }

    while ((queue.isNotEmpty && !shouldStop) || active.isNotEmpty) {
      while (queue.isNotEmpty && active.length < concurrency && !shouldStop) {
        final package = queue.removeFirst();
        late Future<void> future;
        future = runOne(package).whenComplete(() => active.remove(future));
        active.add(future);
      }

      if (active.isNotEmpty) {
        await Future.any(active);
      }
    }

    _reporter.reportSummary(results);

    return results.any((r) => !r.success) ? 1 : 0;
  }
}
