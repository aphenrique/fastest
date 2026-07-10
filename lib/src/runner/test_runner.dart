import 'dart:io';

import 'package:path/path.dart' as path;

import '../coverage_check/coverage_handler.dart';
import '../domain/result_parser.dart';
import '../domain/test_result.dart';
import '../optimizer/test_optimizer.dart';
import '../presentation/result_reporter.dart';
import '../process/process_handler.dart';
import 'runner.dart';
import 'test_arguments_builder.dart';

/// Executor de testes Flutter que gerencia o processo de execução dos testes.
class TestRunner implements Runner {
  /// Cria uma nova instância de TestRunner
  TestRunner({
    required this.testPath,
    this.coverage = false,
    this.concurrency = 1,
    this.failFast = false,
    this.verbose = false,
    this.fvm = false,
    ProcessHandler? processHandler,
  }) : _processHandler = processHandler ?? const DefaultProcessHandler();

  final String testPath;
  final bool coverage;
  final int concurrency;
  final bool failFast;
  final bool verbose;

  /// Executa via `fvm flutter test` em vez de `flutter test`.
  final bool fvm;

  final ProcessHandler _processHandler;

  final _testOptimizer = TestOptimizer();
  final _coverageHandler = CoverageHandler();
  final _argsBuilder = TestArgumentsBuilder();

  String get packageName => path.basename(testPath);

  /// Executa os testes de forma "silenciosa" e devolve um [PackageResult].
  ///
  /// A saída do `flutter test` é interpretada pelo [ResultParser] (camada de
  /// domínio); nada é renderizado aqui, o que permite rodar dentro de isolates
  /// e agregar os resultados na camada de apresentação.
  ///
  /// Quando [echo] é `true`, a saída bruta também é ecoada em tempo real
  /// (usado no modo single-package).
  Future<PackageResult> run({bool echo = false}) async {
    final stopwatch = Stopwatch()..start();

    _coverageHandler.verifyCoverage(testPath, coverage);

    final testFile = _testOptimizer(testPath);
    final args = _argsBuilder.build(
      testFile: testFile,
      coverage: coverage,
      concurrency: concurrency,
    );

    // Com `--fvm`, executa `fvm flutter test`; caso contrário, `flutter test`.
    final executable = fvm ? 'fvm' : 'flutter';
    final commandArgs = fvm ? ['flutter', ...args] : args;

    final process = await _processHandler.startProcess(
      executable,
      commandArgs,
      workingDirectory: testPath,
    );

    final parser = ResultParser(packageName: packageName);
    const decoder = SystemEncoding();

    final stdoutDone = process.stdout.transform(decoder.decoder).forEach((c) {
      parser.addStdout(c);
      if (echo) stdout.write(c);
    });
    final stderrDone = process.stderr.transform(decoder.decoder).forEach((c) {
      parser.addStderr(c);
      if (echo) stderr.write(c);
    });

    await Future.wait([stdoutDone, stderrDone]);
    final exitCode = await process.exitCode;
    stopwatch.stop();

    return parser.build(exitCode: exitCode, duration: stopwatch.elapsed);
  }

  @override
  Future<int> execute() async {
    final result = await run(echo: verbose);
    const ResultReporter().reportSingle(result);
    return result.success ? 0 : (result.exitCode == 0 ? 1 : result.exitCode);
  }
}
