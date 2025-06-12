import 'dart:io';

import 'package:path/path.dart' as path;

import 'colored_output.dart';
import 'console_color.dart';
import 'test_optimizer.dart';

class TestRunner {
  TestRunner(
    this.testOptimizer, {
    this.coverage = false,
    this.concurrency = 4,
    required this.testPath,
  });

  final bool coverage;
  final int concurrency;
  final String testPath;
  final TestOptimizer testOptimizer;

  Future<int> execute() async {
    final testFile = testOptimizer(testPath);

    if (coverage) {
      final coverageDir = Directory(path.join(testPath, 'coverage'));
      if (coverageDir.existsSync()) {
        ColoredOutput.writeln(
          ConsoleColor.yellow,
          '... Removendo pasta coverage antiga',
        );
        coverageDir.deleteSync(recursive: true);
      }
    }

    ColoredOutput.writeln(ConsoleColor.yellow, '... Executando os testes\n');

    final testArgs = [
      'test',
      testFile,
      '--concurrency=$concurrency',
    ];

    if (coverage) {
      testArgs.add('--coverage');
    }

    final process = await Process.start(
      'flutter',
      testArgs,
      runInShell: true,
      workingDirectory: testPath,
      mode: ProcessStartMode.inheritStdio,
    );

    return process.exitCode;
  }
}
