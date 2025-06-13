import 'dart:async';
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

    final output = <String>[];
    final errors = <String>[];

    final packageName = getPackageName(testPath);

    if (coverage) {
      final coverageDir = Directory(path.join(testPath, 'coverage'));

      if (coverageDir.existsSync()) {
        output.add(
          ColoredOutput.line(
            ConsoleColor.yellow,
            '$packageName > Removendo pasta coverage antiga',
          ),
        );
        coverageDir.deleteSync(recursive: true);
      }
    }

    output.add(
      ColoredOutput.line(
        ConsoleColor.yellow,
        '$packageName > Executando os testes',
      ),
    );

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
    }

    return exitCode;
  }

  String getPackageName(String testPath) {
    final packageName = path.basename(testPath);
    return packageName;
  }
}
