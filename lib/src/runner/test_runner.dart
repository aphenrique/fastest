import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../optimizer/test_optimizer.dart';
import '../view/test_output.dart';
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

  final TestOptimizer testOptimizer = TestOptimizer();

  String get packageName => path.basename(testPath);

  @override
  Future<int> execute() async {
    final testOutput = TestOutput(
      verbose,
      packageName: packageName,
      failFast: failFast,
    );
    verifyCoverage(testPath, coverage);

    final testFile = testOptimizer(testPath);

    final process = await Process.start(
      'flutter',
      getTestArgs(testFile, coverage, concurrency),
      runInShell: true,
      workingDirectory: testPath,
    );

    testOutput
      ..output(process.stdout)
      ..error(process.stderr);

    final exitCode = await process.exitCode;

    if (failFast && exitCode != 0) {
      exit(5);
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
