import 'package:path/path.dart' as path;

import '../optimizer/test_optimizer.dart';
import '../process/process_handler.dart';
import '../view/test_output.dart';
import 'coverage_handler.dart';
import 'runner.dart';
import 'test_arguments_builder.dart';

/// Executor de testes Flutter que gerencia o processo de execução dos testes
class TestRunner implements Runner {
  /// Cria uma nova instância de TestRunner
  TestRunner({
    required this.testPath,
    this.coverage = false,
    this.concurrency = 1,
    this.failFast = false,
    this.verbose = false,
    ProcessHandler? processHandler,
    TestOutput? testOutput,
  })  : _processHandler = processHandler ?? const DefaultProcessHandler(),
        _testOutput = testOutput;

  final String testPath;
  final bool coverage;
  final int concurrency;
  final bool failFast;
  final bool verbose;
  final ProcessHandler _processHandler;
  final TestOutput? _testOutput;

  final _testOptimizer = TestOptimizer();
  final _coverageHandler = CoverageHandler();
  final _argsBuilder = TestArgumentsBuilder();

  String get packageName => path.basename(testPath);

  @override
  Future<int> execute() async {
    final testOutput = _testOutput ??
        TestOutput(
          verbose,
          packageName: packageName,
          failFast: failFast,
        );

    _coverageHandler.verifyCoverage(testPath, coverage);

    final testFile = _testOptimizer(testPath);
    final args = _argsBuilder.build(
      testFile: testFile,
      coverage: coverage,
      concurrency: concurrency,
    );

    final process = await _processHandler.startProcess(
      'flutter',
      args,
      workingDirectory: testPath,
    );

    return _processHandler.handleProcessOutput(
      process,
      testOutput.output,
      testOutput.error,
    );
  }
}
