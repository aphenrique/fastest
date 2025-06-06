import 'dart:io';

import 'package:path/path.dart' as path;

import 'colored_output.dart';
import 'console_color.dart';
import 'test_optimizer.dart';

class TestRunner {
  final bool coverage;
  final int concurrency;
  final TestOptimizer testOptimizer;

  TestRunner(
    this.testOptimizer, {
    this.coverage = false,
    this.concurrency = 4,
  });

  Future<void> execute() async {
    final projectPath = Directory.current.path;
    final testFile = testOptimizer(projectPath);

    if (coverage) {
      final coverageDir = Directory(path.join(projectPath, 'coverage'));
      if (coverageDir.existsSync()) {
        ColoredOutput.writeln(
            ConsoleColor.yellow, '... Removendo pasta coverage antiga');
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
      workingDirectory: projectPath,
      mode: ProcessStartMode.inheritStdio,
    );

    exit(await process.exitCode);
  }
}
