import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../optimizer/test_optimizer.dart';
import '../output/colored_output.dart';
import '../output/console_color.dart';
import 'runner.dart';

class TestRunner implements Runner {
  TestRunner({
    required this.testPath,
    this.coverage = false,
    this.concurrency = 1,
    this.failFast = false,
    this.verbose = false,
  });

  final String testPath;
  final bool coverage;
  final int concurrency;
  final bool failFast;
  final bool verbose;

  String get packageName => path.basename(testPath);

  ProcessStartMode get processStartMode =>
      verbose ? ProcessStartMode.inheritStdio : ProcessStartMode.normal;

  @override
  Future<int> execute() async {
    verifyCoverage(testPath, coverage);

    final testFile = TestOptimizer()(testPath);

    final output = <String>[];
    final errors = <String>[];

    output.add(
      ColoredOutput.line(
        ConsoleColor.yellow,
        '$packageName > Executando testes...',
      ),
    );

    final process = await Process.start(
      'flutter',
      getTestArgs(testFile, coverage, concurrency),
      runInShell: true,
      workingDirectory: testPath,
      mode: processStartMode,
    );

    process.stdout.transform(const SystemEncoding().decoder).listen((event) {
      if (event.contains('[E]')) {
        errors.add(
          ColoredOutput.line(
            ConsoleColor.red,
            '$packageName > $event',
          ),
        );
        return;
      }

      if (event.contains('All tests passed!')) {
        output.add(
          ColoredOutput.line(
            ConsoleColor.green,
            '$packageName > $event',
          ),
        );
        return;
      }

      if (event.contains('Some tests failed')) {
        errors.add(
          ColoredOutput.line(
            ConsoleColor.red,
            '$packageName > $event',
          ),
        );
        return;
      }
    });

    process.stderr.transform(const SystemEncoding().decoder).listen((event) {
      if (event.startsWith('Waiting for another flutter command')) {
        return;
      }

      errors.add(event);
    });

    final exitCode = await process.exitCode;

    if (output.isNotEmpty) {
      stdout
        ..write('\r\x1B[K') // Limpa a linha do loading
        ..write(output.join());
    }

    if (errors.isNotEmpty) {
      stdout.write(errors.join());

      if (failFast) {
        /// Exit code 5 is used to indicate that the test failed and the
        /// execution should be interrupted.
        exit(5);
      }
    }

    return exitCode;
  }

  void verifyCoverage(String testPath, bool coverage) {
    if (coverage) {
      final coverageDir = Directory(path.join(testPath, 'coverage'));

      if (coverageDir.existsSync()) {
        coverageDir.deleteSync(recursive: true);
      }
    }
  }

  List<String> getTestArgs(String testFile, bool coverage, int concurrency) {
    final testArgs = ['test', testFile];

    if (concurrency > 1) {
      testArgs.add('--concurrency=$concurrency');
    }

    if (coverage) {
      testArgs.add('--coverage');
    }

    return testArgs;
  }
}
